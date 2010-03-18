------------------------------------------------------------------------------
-- Creation of the TPTP files
------------------------------------------------------------------------------

module TPTP.Files where

-- Haskell imports
import System.FilePath

-- Local imports
import TPTP.Types

------------------------------------------------------------------------------
extTPTP :: String
extTPTP = ".tptp"

axiomsFile :: String
axiomsFile = addExtension "/tmp/externalAxioms" extTPTP

communHeader :: String
communHeader =
    "%-----------------------------------------------------------------------------\n" ++
  "% This file was generated automatically.\n" ++
  "%-----------------------------------------------------------------------------\n\n"

communFooter :: String
communFooter =
  "\n" ++
  "%-----------------------------------------------------------------------------\n"

headerAxioms :: String
headerAxioms =
  communHeader ++
  "% This file corresponds to the EXTERNAL axioms.\n\n"

footerAxioms :: String
footerAxioms =
    communFooter ++
    "% End EXTERNAL axioms.\n"

headerTheorem :: String
headerTheorem =
    communHeader ++
  "% This file corresponds to an EXTERNAL theorem.\n\n" ++
  "% We include the EXTERNAL axioms file. \n" ++
  "include('" ++ axiomsFile ++ "').\n\n"

footerTheorem :: String
footerTheorem =
    communFooter ++
    "% End EXTERNAL theorem.\n"

addAxiom :: LineTPTP -> IO ()
addAxiom line@(MkLineTPTP  _ AxiomTPTP _ ) = appendFile axiomsFile (show line)
addAxiom _                                 = return ()

createAxiomsFile :: [LineTPTP] -> IO ()
createAxiomsFile linesTPTP = do
  _ <- writeFile axiomsFile headerAxioms
  _ <- mapM_ addAxiom linesTPTP
  _ <- appendFile axiomsFile footerAxioms
  return ()

createTheoremFile :: LineTPTP -> IO ()
createTheoremFile line@(MkLineTPTP  name ConjectureTPTP _ ) = do
  let theoremFile = addExtension ("/tmp/" ++ name) extTPTP
  _ <- writeFile theoremFile headerTheorem
  _ <- appendFile theoremFile (show line)
  _ <- appendFile theoremFile footerTheorem
  return ()
createTheoremFile _ = return ()

-- We create a file with all the EXTERNAL axioms and we create a file
-- for each EXTERNAL theorem.
createFilesTPTP :: [LineTPTP] -> IO ()
createFilesTPTP linesTPTP = do
  _ <- createAxiomsFile linesTPTP
  _ <- mapM_ createTheoremFile linesTPTP
  return ()
