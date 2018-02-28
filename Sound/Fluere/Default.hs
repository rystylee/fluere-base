module Sound.Fluere.Default where

import Control.Concurrent.STM (TVar)
import Data.Map (Map)
import Sound.OSC.FD (Datum, string, float)

import Sound.Fluere.BaseData
import Sound.Fluere.Time (currentTime)
import Sound.Fluere.Clock (newClock, newClockMMap)
import Sound.Fluere.Player (newPlayer, newPlayerMMap)
import Sound.Fluere.FluereWorld (newFluereWorld)


-- These functions are used to get a default data
--
defaultClock :: IO Clock
defaultClock = do
    starttime <- currentTime
    let cname = "defaultClock"
        bpm   = 60
        beat = 4
    return $  newClock cname bpm beat starttime

defaultPlayer :: Player
defaultPlayer = newPlayer "defaultPlayer" [string "kick1", string "freq", float 440] [[1,0,1,0], [1,1,1,1]] Pausing

defaultFluereWorld :: IO FluereWorld
defaultFluereWorld = do
    cmmap <- defaultClockMMap
    pmmap <- defaultPlayerMMap
    return $ newFluereWorld "defaultWorld" cmmap pmmap
--
--

-- These functions are used to get a default MutableMaps
--
defaultClockMMap :: IO (TVar (Map String Clock))
defaultClockMMap = do
    c <- defaultClock
    newClockMMap c

defaultPlayerMMap :: IO (TVar (Map String Player)) 
defaultPlayerMMap = newPlayerMMap defaultPlayer
--
--
