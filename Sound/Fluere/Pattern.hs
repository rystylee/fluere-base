module Sound.Fluere.Pattern ( newPattern
                            , newPatternMMap
                            , addPattern
                            , nextPlayerNote
                            , modifyDurations
                            ) where

import Sound.Fluere.Data
import Sound.Fluere.MutableMap (MutableMap, fromListM, insertM, lookupM)


---------------------------------------------------------------------
-- Construction
---------------------------------------------------------------------

newPattern :: String -> [Int] -> Pattern
newPattern n d =
    Pattern { patternName = n
            , durations = d
            , index = 0
            }

newPatternMMap :: Pattern -> IO (MutableMap String Pattern)
newPatternMMap pattern = fromListM [(patternName pattern, pattern)]

addPattern :: DataBase -> Pattern -> IO ()
addPattern db pattern = insertM (patternName pattern) pattern $ patternMMap db

---------------------------------------------------------------------
-- Modify
---------------------------------------------------------------------

modifyPattern :: DataBase -> String -> (Pattern -> Pattern) -> IO ()
modifyPattern db n f = do
    let pmmap = patternMMap db
    Just p <- lookupM n pmmap
    let newp = f p
    insertM n newp pmmap

modifyDurations :: DataBase -> String -> [Int] -> IO ()
modifyDurations db n newd = modifyPattern db n modifyds
    where modifyds p = p { durations = newd, index = 0 }

modifyIndex :: DataBase -> String -> Int -> IO ()
modifyIndex db n newi = modifyPattern db n modifyi
    where modifyi p = p { index = newi }

---------------------------------------------------------------------
-- used to get player's next note
---------------------------------------------------------------------

nextPlayerNote :: DataBase -> String -> IO Int
nextPlayerNote db n = do
    Just p <- lookupM n $ playerMMap db
    Just pattern <- lookupM (playerPattern p) (patternMMap db)
    let ds = convertN $ durations pattern
        i = index pattern
    if (i == (length ds - 1))
        then do
            modifyIndex db (playerPattern p) 0
        else do
            modifyIndex db (playerPattern p) (i + 1)
    Just pattern <- lookupM (playerPattern p) (patternMMap db)
    return $ ds !! i

-- ex.) [2,1,1.5]
convertN :: [Int] -> [Int]
convertN xs = concat $  map convert xs

convert :: Int -> [Int]
convert 0 = [0]
convert x = [1] ++ replicate (x - 1) 0
