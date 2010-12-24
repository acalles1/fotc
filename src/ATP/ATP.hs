-----------------------------------------------------------------------------
-- Call the ATPs
-----------------------------------------------------------------------------

{-# LANGUAGE CPP #-}
{-# LANGUAGE UnicodeSyntax #-}

module ATP.ATP ( callATPsOnConjecture ) where

-- Haskell imports
import Data.List               ( isInfixOf )
import Data.Maybe              ( fromMaybe )
import Control.Exception       ( evaluate )
import Control.Concurrent      ( forkIO, threadDelay )
import Control.Concurrent.MVar ( MVar, newEmptyMVar, putMVar, takeMVar )
import Control.Monad           ( unless, when )
import Control.Monad.Error     ( throwError )
import Control.Monad.State     ( get )
import Control.Monad.Trans     ( liftIO )
import System.IO               ( hGetContents, hPutStrLn, stderr )
import System.Process
    ( createProcess
    , proc
    , ProcessHandle
    , StdStream(CreatePipe)
    , std_out
    , terminateProcess
    )
-- import System.Timeout ( timeout )

-- Agda library imports
import Agda.Utils.Impossible ( Impossible(Impossible) , throwImpossible )

-- Local imports
import Monad.Base    ( T, TState(tOpts) )
import Monad.Reports ( reportS )
import Options    ( Options(optATP, optOnlyFiles, optTime, optUnprovedError) )
import TPTP.Files ( createConjectureFile )
import TPTP.Types ( ConjectureAFs, GeneralRolesAF )

#include "../undefined.h"

------------------------------------------------------------------------------
-- The ATPs.
data ATP = E
         | Equinox
         | IleanCoP
         | Metis
         | Vampire
           deriving (Eq, Show)

-- The vampire executables are vampire_lin32, vampire_lin64,
-- vampire_mac, and vampire_win.exe, therefore I use the generic
-- name "vampire".
atp2exec :: ATP → String
atp2exec E        = "eprover"
atp2exec Equinox  = "equinox"
atp2exec IleanCoP = "ileancop.sh"
atp2exec Metis    = "metis"
atp2exec Vampire  = "vampire"

optATP2ATP :: String → ATP
optATP2ATP "e"        = E
optATP2ATP "equinox"  = Equinox
optATP2ATP "ileancop" = IleanCoP
optATP2ATP "metis"    = Metis
optATP2ATP "vampire"  = Vampire
optATP2ATP _          = __IMPOSSIBLE__

-- Tested with E 1.2 Badamtam.
eOk :: String
eOk = "Proof found!"

-- Tested with Equinox 5.0alpha (2010-06-29).
equinoxOk :: String
equinoxOk = "+++ RESULT: Theorem"

-- Tested with Metis 2.3 (release 20101019).
metisOk :: String
metisOk = "SZS status Theorem"

-- Tested with ileanCoP 1.3 beta1.
ileancopOk :: String
ileancopOk = "Intuitionistic Theorem"

-- Tested with Vampire 0.6 (revision 903)
vampireOk :: String
vampireOk = "Termination reason: Refutation"

checkOutputATP :: ATP → String → Bool
checkOutputATP atp output = atpOk atp `isInfixOf` output
    where
      atpOk :: ATP → String
      atpOk E        = eOk
      atpOk Equinox  = equinoxOk
      atpOk IleanCoP = ileancopOk
      atpOk Metis    = metisOk
      atpOk Vampire  = vampireOk

-- Equinox bug? The option --no-progress don't make any difference.
argsATP :: ATP → Int → FilePath → [String]
argsATP E        timeLimit file = [ "--cpu-limit=" ++ show timeLimit
                                  , "--output-level=0"
                                  , "--tstp-format"
                                  , file
                                  ]
argsATP Equinox  timeLimit file = [ "--no-progress"
                                  , "--time", show timeLimit
                                  , file
                                  ]
-- N.B. The order of the IleanCop arguments is fixed.
argsATP IleanCoP timeLimit file = [ file
                                  , show timeLimit
                                  ]
argsATP Metis    timeLimit file = [ "--time-limit", show timeLimit
                                  , file
                                  ]
argsATP Vampire  timeLimit file = [ "--input_file", file
                                  , "-t", show timeLimit
                                  ]

runATP :: ATP → MVar (Bool, ATP) → [String] → IO ProcessHandle
runATP atp outputMVar args = do

    -- To create the ATPs process we follow the ideas used by
    -- System.Process.readProcess.

    (_, outputH, _, atpPH) ←
      createProcess (proc (atp2exec atp) args)
                    { std_out = CreatePipe }

    output ← hGetContents $ fromMaybe __IMPOSSIBLE__ outputH
    _      ← forkIO $
               evaluate (length output) >>
               putMVar outputMVar (checkOutputATP atp output, atp)

    return atpPH

answerATPs :: MVar (Bool, ATP) → [ProcessHandle] → FilePath → Int → T ()
answerATPs outputMVar atpsPH file n = do

  state ← get

  let opts :: Options
      opts = tOpts state

  let atps :: [String]
      atps = optATP opts

  if n == length atps
    then do
      let msg :: String
          msg = "The ATP(s) " ++ show atps ++
                " did not prove the conjecture in " ++ file
      if optUnprovedError opts
        then throwError msg
        else liftIO $ hPutStrLn stderr $ msg
    else do
      output ← liftIO $ takeMVar outputMVar
      case output of
        (True, atp) → do
          reportS "" 1 $ show atp ++ " proved the conjecture in " ++ file
          liftIO $ do
            -- It seems that terminateProcess is a nop if the process
            -- is finished, therefore we don't care on terminate all
            -- the ATPs processes.

            -- TODO: Ugly hack. Using the thread delay and repeating
            -- the terminateProcess instruction was the way to kill
            -- the Vampire process.
            mapM_ terminateProcess atpsPH
            threadDelay 500000
            mapM_ terminateProcess atpsPH

        (False, _) → answerATPs outputMVar atpsPH file (n + 1)

callATPsOnConjecture :: GeneralRolesAF → ConjectureAFs → T ()
callATPsOnConjecture generalRolesAF conjectureAFs = do

  state ← get

  let opts :: Options
      opts = tOpts state

  file ← createConjectureFile generalRolesAF conjectureAFs

  when (optOnlyFiles opts) $
    reportS "" 1 $ "Created the conjecture file " ++ file

  unless (optOnlyFiles opts) $ do

    let atps :: [String]
        atps = optATP opts

    when (null atps) __IMPOSSIBLE__

    let timeLimit :: Int
        timeLimit = optTime opts

    outputMVar ← liftIO (newEmptyMVar :: IO (MVar (Bool, ATP)))

    reportS "" 1 $ "Proving the conjecture in " ++ file ++ " ..."
    reportS "" 20 $ "ATPs to be used: " ++ show atps

    atpsPH ← liftIO $
           mapM ((\atp → runATP atp outputMVar (argsATP atp timeLimit file)) .
                 optATP2ATP)
                atps

    answerATPs outputMVar atpsPH file 0
