{-# LANGUAGE OverloadedStrings, RecursiveDo #-}

import Reflex
import Reflex.Dom
import Control.Monad
import Control.Monad.IO.Class
import qualified Data.Map as Map
import qualified Data.Text as T

main :: IO ()
main = mainWidgetWithHead headElement bodyElement

headElement :: MonadWidget t m => m ()
headElement = do
  el "title" (text "SputnikVM Development Environment")
  styleSheet "css/style.css"
  where
    styleSheet link = elAttr "link" (Map.fromList [
                                        ("rel", "stylesheet")
                                        , ("type", "text/css")
                                        , ("href", link)
                                        ]) $ return ()

bodyElement :: MonadWidget t m => m ()
bodyElement = do
  el "h1" (text "SputnikVM Development Environment")
  request <- do
    rec transactionHash <- textInput $
          def & setValue .~ fmap (\_ -> "") debugSend
        debugSend <- button "Debug"
    return $ ffilter (/="") $ tag (current (value transactionHash)) debugSend
  response <- fmap (fmap _xhrResponse_responseText) $ performRequestAsync $ fmap requestFromHash request
  dynText <=< holdDyn "" $ fmapMaybe id response

requestFromHash :: T.Text -> XhrRequest T.Text
requestFromHash hash =
  XhrRequest "POST" "http://127.0.0.1:8545" $
    (XhrRequestConfig
     { _xhrRequestConfig_sendData = T.concat [ "{\"method\": \"debug_traceTransaction\","
                                             , "\"params\": [\"", hash, "\"],"
                                             , "\"jsonrpc\": \"2.0\","
                                             , "\"id\": 1}"
                                             ]
     , _xhrRequestConfig_headers = Map.singleton "Content-Type" "application/json"
     , _xhrRequestConfig_user = Nothing
     , _xhrRequestConfig_password = Nothing
     , _xhrRequestConfig_responseType = Nothing
     , _xhrRequestConfig_responseHeaders = def
     , _xhrRequestConfig_withCredentials = False
     })
