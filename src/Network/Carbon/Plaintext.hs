{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE CPP #-}
module Network.Carbon.Plaintext
  ( -- * Interacting with Carbon
    -- ** Connections
    Connection(..)
  , connect
  , disconnect

    -- ** Metrics
  , sendMetrics
  , sendMetric
  , Metric(..)

    -- * Protocol details
  , encodeMetric
  )
  where

import Control.Exception (bracketOnError)
import Data.Typeable (Typeable)
import System.IO.Error

import qualified Data.ByteString.Builder as Builder
import qualified Data.Time as Time
import qualified Data.Time.Clock.POSIX as Time
import qualified Data.Vector as V
import qualified Data.Text as Text
import qualified Data.Text.Encoding as Text
import qualified Network.Socket as Network
import qualified Network.Socket.ByteString.Lazy as Network

#if !MIN_VERSION_base(4, 14, 0)
import GHC.IO.Exception ( IOErrorType( ResourceVanished ) )

isResourceVanishedError :: IOError -> Bool
isResourceVanishedError err = (ioeGetErrorType err) == ResourceVanished
#endif

--------------------------------------------------------------------------------
-- | Low-level representation of a Carbon connection. It's suggested that you
-- construct this via 'connect'. It is henceforth assumed that
-- 'Network.getPeerName' will return something useful, which usually means
-- 'connectionSocket' should have been 'Network.connect'ed at least once.
data Connection = Connection
  { connectionSocket :: !Network.Socket
    -- ^ The connection socket to Carbon.
  }
  deriving (Eq, Show, Typeable)


--------------------------------------------------------------------------------
-- | Connect to Carbon.
connect :: Network.SockAddr -> IO Connection
connect sockAddr = fmap Connection $ do
  let openSocket = Network.socket Network.AF_INET Network.Stream Network.defaultProtocol
  bracketOnError openSocket
                 Network.close
                 (\s -> fmap (const s) (Network.connect s sockAddr))


--------------------------------------------------------------------------------
-- | Disconnect from Carbon. Note that it's still valid to 'sendMetrics' to this
-- 'Connection', and it will result in a reconnection.
disconnect :: Connection -> IO ()
disconnect (Connection s) = Network.close s


--------------------------------------------------------------------------------
reconnect :: Connection -> IO ()
reconnect (Connection s) = do
  peer <- Network.getPeerName s
  Network.connect s peer


--------------------------------------------------------------------------------
-- | A single data point. A metric has a path that names it, a value, and the
-- time the metric was sampled.
data Metric = Metric
  { metricPath :: !Text.Text
  , metricValue :: !Double
  , metricTimeStamp :: !Time.UTCTime
  }
  deriving (Eq, Show, Typeable)


--------------------------------------------------------------------------------
-- | Send a collection of metrics to Carbon.
sendMetrics :: Connection -> V.Vector Metric -> IO ()
sendMetrics c ms = do
  let socket = connectionSocket c

  catchIOError
    (Network.sendAll socket (Builder.toLazyByteString (V.foldl' mappend mempty (V.map encodeMetric ms))))
    (\e -> if isResourceVanishedError e then reconnect c >> sendMetrics c ms else ioError e)

--------------------------------------------------------------------------------
-- | Send a single metric.
sendMetric :: Connection -> Text.Text -> Double -> Time.UTCTime -> IO ()
sendMetric c k v t = sendMetrics c (V.singleton (Metric k v t))


--------------------------------------------------------------------------------
-- | Encode a 'Metric' for transmission over the plain text protocol.
encodeMetric :: Metric -> Builder.Builder
encodeMetric (Metric k v t) =
  Builder.byteString (Text.encodeUtf8 k) <> " " <>
  Builder.stringUtf8 (show v) <> " " <>
  Builder.stringUtf8 (show (round (Time.utcTimeToPOSIXSeconds t) :: Int)) <> "\n"
