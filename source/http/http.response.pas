(******************************************************************************)
(*                                 libPasCURL                                 *)
(*                 object pascal wrapper around cURL library                  *)
(*                        https://github.com/curl/curl                        *)
(*                                                                            *)
(* Copyright (c) 2020                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpascurl                  ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)

unit http.response;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  Classes, SysUtils, libpascurl, curlresult, timeinterval, datasize, errorstack,
  httpstatuscode, curlstringlist;

type
  { HTTP(S) session result response data }
  THTTPResponse = class
  public
    type
      { HTTP(S) session errors }
      IError = interface
        { Return TRUE if has errors }
        function HasErrors : Boolean;

        { Return all errors stack }
        function Errors : TErrorStack;
      end;

      { HTTP(S) session request }
      TRequest = class
      public
        { Get size of sent request }
        function Length : TDataSize;
      private
        constructor Create(ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;

      { HTTP(S) session headers }
      THeader = class
      public
        type
          { HTTP protocol version }
          THTTPVersion = (
            HTTP_UKNOWN                   = CURL_HTTP_VERSION_NONE,
            { Enforce HTTP 1.0 requests. }
            HTTP_1_0                      = CURL_HTTP_VERSION_1_0,
            { Enforce HTTP 1.1 requests. }
            HTTP_1_1                      = CURL_HTTP_VERSION_1_1,
            { Attempt HTTP 2 requests. Will fall back to HTTP 1.1 if
              HTTP 2 can't be negotiated with the server. }
            HTTP_2_0                      = CURL_HTTP_VERSION_2_0,
            { Attempt HTTP 2 over TLS (HTTPS) only. Will fall back to
              HTTP 1.1 if HTTP 2 can't be negotiated with the HTTPS server. For
              clear text HTTP servers, libcurl will use 1.1. }
            HTTP_2_0_TLS                  = CURL_HTTP_VERSION_2TLS,
            { Issue non-TLS HTTP requests using HTTP/2 without HTTP/1.1 Upgrade.
              It requires prior knowledge that the server supports HTTP/2
              straight away. HTTPS requests will still do HTTP/2 the standard
              way with negotiated protocol version in the TLS handshake. }
            HTTP_2_PRIOR_KNOWEDGE         = CURL_HTTP_VERSION_2_PRIOR_KNOWLEDGE,
            { Setting this value will make libcurl attempt to use HTTP/3
              directly to server given in the URL. Note that this cannot
              gracefully downgrade to earlier HTTP version if the server doesn't
              support HTTP/3. For more reliably upgrading to HTTP/3, set the
              preferred version to something lower and let the server announce
              its HTTP/3 support via Alt-Svc:. }
            HTTP_3_0                      = CURL_HTTP_VERSION_3
          );
      public
        { Get the CONNECT response code
          Received HTTP proxy response code to a CONNECT request. }
        function ConnectStatusCode : THTTPStatusCode;
          {$IFNDEF DEBUG}inline;{$EDNIF}

        { Get the response code }
        function StatusCode : THTTPStatusCode;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the HTTP version used in the connection }
        function Version : THTTPVersion;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get size of retrieved headers }
        function Length : TDataSize;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
        destructor Destroy; override;

        { This function gets called by libcurl as soon as it has received header
          data. The header callback will be called once for each header and only
          complete header lines are passed on to the callback. }
        class function HeaderFunctionCallback(buffer : PChar; size : LongWord;
          nitems : LongWord; userdata : Pointer) : LongWord;
        function HeaderCallback (buffer : PChar; size : LongWord; nitems :
          LongWord) : LongWord;
      private
        FCurl : CURL;
        FHeaders : TStringList;
        FErrors : PErrorStack;
      end;

      { HTTP(S) session redirected options }
      TRedirect = class
      public
        { Return TRUE if request is redirected }
        function IsRedirected : Boolean;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return redirect count times }
        function Count : Longint;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return redirected URL }
        function Url : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Return the time for all redirection steps }
        function TotalTime : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create(ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;

      { HTTP(S) content data }
      TContent = class
      public
        { Get Content-Type
          This is the value read from the Content-Type: field. If you get empty,
          it means that the server didn't send a valid Content-Type header. }
        function ContentType : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get content-length of download }
        function Length : TDataSize;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get content as string }
        function ToString : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get content as bytes array }
        function ToBytes : TMemoryStream;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;

      { Get all known cookies }
      TCookies = class
      public
        type
          { Cookies enumerator }
          TCookiesEnumerator = class
          protected

            FPosition : Cardinal;
            function GetCurrent : String;
              {$IFNDEF DEBUG}inline;{$ENDIF}
          public
            constructor Create;
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TCookiesEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            property Current : String read GetCurrent;
          end;
        public
          { Get cookies enumerator }
          function GetEnumerator : TCookiesEnumerator;
            {$IFNDEF DEBUG}inline;{$ENDIF}
        private
          constructor Create (ACurl : CURL; AErrors : PErrorStack);        
        private
          FCurl : CURL;
          FErrors : PErrorStack;
          FList : TCurlStringList;
        end;

      { HTTP(S) session timeouts }
      TTimeout = class
      public
        { Get transfer total time }
        function Total : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the name lookup time }
        function NameLookup : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the time until connect }
        function Connect : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the time until the SSL/SSH handshake is completed }
        function AppConnect : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the time until the file transfer start }
        function PreTransfer : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get time until the first byte is received }
        function StartTransfer : TTimeInterval;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;

      { HTTP(S) session speed data }
      TSpeed = class
      public
        { Get download speed per second }
        function Download : TDataSize;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get upload speed per second }
        function Upload : TDataSize;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;

      {  }
      TSecure = class
      public
        type
          { SSL verify result code }
          TSSLResult = (
            { The operation was successful }
            ERR_OK                                                       = 0,
            
            { Unable to get issuer certificate" the issuer certificate could not 
              be found: this occurs if the issuer certificate of an untrusted 
              certificate cannot be found }
            ERR_UNABLE_TO_GET_ISSUER_CERT                                = 2,
            
            { The CRL of a certificate could not be found }
            ERR_UNABLE_TO_GET_CRL { UNUSED }                             = 3,

            { The certificate signature could not be decrypted. This means that 
              the actual signature value could not be determined rather than it 
              not matching the expected value, this is only meaningful for RSA 
              keys. }
            ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE                         = 4,

            { The CRL signature could not be decrypted: this means that the 
              actual signature value could not be determined rather than it not 
              matching the expected value. }
            ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE { UNUSED }               = 5,

            { The public key in the certificate SubjectPublicKeyInfo could not 
              be read. }
            ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY                       = 6,

            { The signature of the certificate is invalid. }
            ERR_CERT_SIGNATURE_FAILURE                                   = 7,

            { The signature of the certificate is invalid. }
            ERR_CRL_SIGNATURE_FAILURE { UNUSED }                         = 8,

            { The certificate is not yet valid: the notBefore date is after the 
              current time. }
            ERR_CERT_NOT_YET_VALID                                       = 9, 

            { The certificate has expired: that is the notAfter date is before 
              the current time. }
            ERR_CERT_HAS_EXPIRED                                         = 10,

            { The CRL is not yet valid. }
            ERR_CRL_NOT_YET_VALID { UNUSED }                             = 11,

            { The CRL has expired. }
            ERR_CRL_HAS_EXPIRED { UNUSED }                               = 12,

            { The certificate notBefore field contains an invalid time. }
            ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD                           = 13,

            { The certificate notAfter field contains an invalid time. }
            ERR_ERROR_IN_CERT_NOT_AFTER_FIELD                            = 14,

            { The CRL lastUpdate field contains an invalid time. }
            ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD { UNUSED }                = 15,

            { The CRL nextUpdate field contains an invalid time. }
            ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD { UNUSED }                = 16,

            { An error occurred trying to allocate memory. This should never 
              happen. }
            ERR_OUT_OF_MEM                                               = 17, 

            { The passed certificate is self signed and the same certificate 
              cannot be found in the list of trusted certificates. }
            ERR_DEPTH_ZERO_SELF_SIGNED_CERT                              = 18,

            { The certificate chain could be built up using the untrusted 
              certificates but the root could not be found locally. }
            ERR_SELF_SIGNED_CERT_IN_CHAIN                                = 19,

            { The issuer certificate of a locally looked up certificate could 
              not be found. This normally means the list of trusted certificates 
              is not complete. }
            ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY                        = 20,

            { No signatures could be verified because the chain contains only 
              one certificate and it is not self signed. }
            ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE                          = 21,

            { The certificate chain length is greater than the supplied maximum 
              depth. }
            ERR_CERT_CHAIN_TOO_LONG { UNUSED }                           = 22,

            { The certificate has been revoked. }
            ERR_CERT_REVOKED { UNUSED }                                  = 23,

            { A CA certificate is invalid. Either it is not a CA or its 
              extensions are not consistent with the supplied purpose. }
            ERR_INVALID_CA                                               = 24,

            { The basicConstraints pathlength parameter has been exceeded. }
            ERR_PATH_LENGTH_EXCEEDED                                     = 25,

            { The supplied certificate cannot be used for the specified 
              purpose. }
            ERR_INVALID_PURPOSE                                          = 26,

            { The root CA is not marked as trusted for the specified purpose. }
            ERR_CERT_UNTRUSTED                                           = 27,

            { The root CA is marked to reject the specified purpose. }
            ERR_CERT_REJECTED                                            = 28,

            { The current candidate issuer certificate was rejected because its 
              subject name did not match the issuer name of the current 
              certificate. Only displayed when the -issuer_checks option is 
              set. }
            ERR_SUBJECT_ISSUER_MISMATCH                                  = 29,

            { The current candidate issuer certificate was rejected because its 
              subject key identifier was present and did not match the authority 
              key identifier current certificate. Only displayed when the 
              -issuer_checks option is set. }
            ERR_AKID_SKID_MISMATCH                                       = 30,

            { The current candidate issuer certificate was rejected because its 
              issuer name and serial number was present and did not match the 
              authority key identifier of the current certificate. Only 
              displayed when the -issuer_checks option is set. }
            ERR_AKID_ISSUER_SERIAL_MISMATCH                              = 31,

            { The current candidate issuer certificate was rejected because its 
              keyUsage extension does not permit certificate signing. }
            ERR_KEYUSAGE_NO_CERTSIGN                                     = 32,

            { An application specific error. }
            ERR_APPLICATION_VERIFICATION { UNUSED }                      = 50 
          );

          { HTTP(S) auth methods }
          THTTPAuthMethod = (
            { No HTTP authentication. 
              A request does not contain any authentication information. This is 
              equivalent to granting everyone access to the resource. }
            AUTH_NONE                                      = CURLAUTH_NONE,

            { HTTP Basic authentication (default). 
              Basic authentication sends a Base64-encoded string that contains a 
              user name and password for the client. Base64 is not a form of 
              encryption and should be considered the same as sending the user 
              name and password in clear text. If a resource needs to be 
              protected, strongly consider using an authentication scheme other 
              than basic authentication. }
            AUTH_BASIC                                     = CURLAUTH_BASIC,

            { HTTP Digest authentication. 
              Digest access authentication is one of the agreed-upon methods a 
              web server can use to negotiate credentials, such as username or 
              password, with a user's web browser. This can be used to confirm 
              the identity of a user before sending sensitive information, such 
              as online banking transaction history. It applies a hash function 
              to the username and password before sending them over the network. 
              In contrast, basic access authentication uses the easily 
              reversible Base64 encoding instead of hashing, making it 
              non-secure unless used in conjunction with TLS. }
            AUTH_DIGEST                                    = CURLAUTH_DIGEST,

            { HTTP Negotiate (SPNEGO) authentication }
            AUTH_NEGOTIATE                                 = CURLAUTH_NEGOTIATE,

            { HTTP NTLM authentication }
            AUTH_NTLM                                      = CURLAUTH_NTLM,

            { HTTP Digest authentication with IE flavour }
            AUTH_DIGEST_IE                                 = CURLAUTH_DIGEST_IE,

            { HTTP NTLM authentication delegated to winbind helper }
            AUTH_NTLM_WB                                   = CURLAUTH_NTLM_WB,

            { HTTP Bearer token authentication }
            AUTH_BEARER                                    = CURLAUTH_BEARER
          );
 
          { SSL engines enumerator }
          TSSLEnginesEnumerator = class
          protected
            FList : TCurlStringList;
            FPosition : Cardinal;

            function GetCurrent : String;
              {$IFNDEF DEBUG}inline;{$ENDIF}
          public
            constructor Create;
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TSSLEnginesEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            property Current : String read GetCurrent;
          end;

          { TLS info enumerator }
          TTLSInfoEnumerator = class
          protected

            FPosition : Cardinal;

          public
            constructor Create;
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TTLSInfoEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}

          end;

          { TLS chain enumerator }
          TTLSChainEnumerator = class
          protected

            FPosition : Cardinal;

          public
            constructor Create;
            function MoveNext : Boolean;
              {$IFNDEF DEBUG}inline;{$ENDIF}
            function GetEnumerator : TTLSChainEnumerator;
              {$IFNDEF DEBUG}inline;{$ENDIF}
          end;
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
      public
        {  }
        function SSLEngines : TSSLEnginesEnumerator;
          {$IFNDEF DEBUG}inline;{$ENDIF}
        
        {  }
        function SSLResult : TSSLResult;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        {  }
        function SSLProxyResult : TSSLResult;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        {  }
        function TLSInfo : TTLSInfoEnumerator;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        {  }
        function TLSChain : TTLSChainEnumerator;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        
      end; 

      { Additional response information }
      TInfo = class
      public
        { Get number of created connections }
        function ConnectionsCount : Cardinal;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get IP address of last connection }
        function ConnectedIP : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the latest destination port number }
        function ConnectedPort : Word;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get local IP address of last connection }
        function LocalIP : String;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the latest local port number }
        function LocalPort : Word;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the last socket used
          If the socket is no longer valid, -1 is returned. }
        function LastSocket : curl_socket_t;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get the active socket }
        function ActiveSocket : curl_socket_t;
          {$IFNDEF DEBUG}inline;{$ENDIF}

        { Get private pointer }
        function UserData : Pointer;
          {$IFNDEF DEBUG}inline;{$ENDIF}
      private
        constructor Create (ACurl : CURL; AErrors : PErrorStack);
      private
        FCurl : CURL;
        FErrors : PErrorStack;
      end;
  private
    FError : TError;
    FRedirect : TRedirect;
    FTimeout : TTimeout;
  end;

implementation

uses
  http.response.error;

{ THTTPResponse.TRequest }

constructor THTTPResponse.TRequest.Create(ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

function THTTPResponse.TRequest.Length : TDataSize;
var
  bytes : Longint = 0;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_REQUEST_SIZE, @bytes));
  Result := TDataSize.Create;
  Result.Bytes := bytes;
end;

{ THTTPResponse.THeader }

constructor THTTPResponse.THeader.Create(ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FHeaders := TStringList.Create;
  FErrors := AErrors;
end;

destructor THTTPResponse.THeader.Destroy;
begin
  FreeAndNil(AHeader);
  inherited Destroy;
end;

class function THTTPResponse.THeader.HeaderFunctionCallback(buffer : PChar;
  size : LongWord; nitems : LongWord; userdata : Pointer) : LongWord;
begin
  Result := THeader(userdata).HeaderCallback(buffer, size, nitems);
end;

function THTTPResponse.THeader.HeaderCallback(buffer : PChar; size : LongWord;
  nitems : LongWord) : LongWord;
begin
  FHeaders.Add(buffer);
  Result := size * nitems;
end;

function THTTPResponse.THeader.ConnectStatusCode : THTTPStatusCode;
var
  Code : Longint = 0;
begin
  FErrors.Push(curl_easy_getinfo(FCurl, CURLINFO_HTTP_CONNECTCODE, @Code));
  Result := THTTPStatusCode(Code);
end;

function THTTPResponse.THeader.StatusCode : THTTPStatusCode;
var
  Code : Longint = 0;
begin
  FErrors.Push(curl_easy_getinfo(FCurl, CURLINFO_RESPONSE_CODE, @Code));
  Result := THTTPStatusCode(Code);
end;

function THTTPResponse.THeader.Version : THTTPVersion;
var
  version : Longint = 0;
begin
  FErrors.Push(curl_easy_getinfo(FCurl, CURLINFO_HTTP_VERSION, @version));
  Result := THTTPVersion(version);
end;

function THTTPResponse.THeader.Length : TDataSize;
var
  bytes : LongWord = 0;
begin
  FErrors.Push(curl_easy_getinfo(FCurl, CURLINFO_HEADER_SIZE, @bytes));
  Result := TDataSize.Create;
  Result.Bytes := bytes;
end;

{ THTTPResponse.TRedirect }

constructor THTTPResponse.TRedirect.Create (ACurl : CURL;
  AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErorrs;

  FollowRedirect := True;
end;

function THTTPResponse.TRedirect.IsRedirected : Boolean;
begin
  Result := Count > 0;
end;

function THTTPResponse.TRedirect.Count : Longint;
begin
  Result := 0;
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_REDIRECT_COUNT, @Result));
end;

function THTTPResponse.TRedirect.Url : String;
var
  url : PChar;
begin
  New(url);
  url := '';
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_REDIRECT_URL, @url));
  Result := url;
end;

function THTTPResponse.TRedirect.TotalTime : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_REDIRECT_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_REDIRECT_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

{ THTTPResponse.TContent }

constructor THTTPResponse.TContent.Create(ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

function THTTPResponse.TContent.ContentType : String;
var
  ctype : PChar;
begin
  New(ctype);
  ctype := '';
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_CONTENT_TYPE, @ctype));
  Result := ctype;
end;

function THTTPResponse.TContent.Length : TDataSize;
var
  size : Longword = 0;
  dsize : Double = 0;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_CONTENT_LENGTH_DOWNLOAD_T,
    @size);
  Result := TDataSize.Create;
  Result.Bytes := size;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_CONTENT_LENGTH_DOWNLOAD,
      @dsize);
    Result.Bytes := ceil(dsize);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TContent.ToString : String;
begin
  // TODO
end;

function THTTPResponse.TContent.ToBytes : TMemoryStream;
begin
  // TODO
end;

{ THTTPResponse.TCookies }

constructor THTTPResponse.TCoookies.Create (ACurl : CURL; AErrors :
  PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

{ THTTPResponse.TTimeout }

constructor THTTPResponse.TTimeout.Create(ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

function THTTPResponse.TTimeout.Total : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_TOTAL_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_TOTAL_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TTimeout.NameLookup : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_NAMELOOKUP_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_NAMELOOKUP_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TTimeout.Connect : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_CONNECT_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_CONNECT_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TTimeout.AppConnect : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_APPCONNECT_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_APPCONNECT_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TTimeout.PreTransfer : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_PRETRANSFER_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_PRETRANSFER_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TTimeout.StartTransfer : TTimeInterval;
var
  time : Longword = 0;
  dtime : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_STARTTRANSFER_TIME_T, @time);
  Result := TTimeInterval.Create;
  Result.Milliseconds := time;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_STARTTRANSFER_TIME, @dtime);
    Result.Milliseconds := ceil(dtime);
  end;

  FErrors^.Push(CurlResult);
end;

{ THTTPResponse.TSpeed }

constructor THTTPResponse.TSpeed.Create (ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

function THTTPResponse.TSpeed.Download : TDataSize;
var
  bytes : LongWord = 0;
  dbytes : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_SPEED_DOWNLOAD_T, @bytes);
  Result := TDataSize.Create;
  Result.Bytes := bytes;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_SPEED_DOWNLOAD, @dbytes);
    Result.Bytes := ceil(dbytes);
  end;

  FErrors^.Push(CurlResult);
end;

function THTTPResponse.TSpeed.Upload : TDataSize;
var
  bytes : LongWord = 0;
  dbytes : Double = 0;
  CurlResult : CURLcode;
begin
  CurlResult := curl_easy_getinfo(FCurl, CURLINFO_SPEED_UPLOAD_T, @bytes);
  Result := TDataSize.Create;
  Result.Bytes := bytes;

  if CurlResult <> CURLE_OK then
  begin
    CurlResult := curl_easy_getinfo(FCurl, CURLINFO_SPEED_UPLOAD, @dbytes);
    Result.Bytes := ceil(dbytes);
  end;

  FErrors^.Push(CurlResult);
end;

{ THTTPResponse.TInfo }

constructor THTTPResponse.TInfo.Create (ACurl : CURL; AErrors : PErrorStack);
begin
  FCurl := ACurl;
  FErrors := AErrors;
end;

function THTTPResponse.TInfo.ConnectionsCount : Cardinal;
var
  count : Longint;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_NUM_CONNECTS, @count));
  Result := count;
end;

function THTTPResponse.TInfo.ConnectedIP : String;
var
  ip : PChar;
begin
  New(ip);
  ip := '';
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_PRIMARY_IP, @ip));
  Result := ip;
end;

function THTTPResponse.TInfo.ConnectedPort : Word;
var
  port : Longint;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_PRIMARY_PORT, @port));
  Result := port;
end;

function THTTPResponse.TInfo.LocalIP : String;
var
  ip : PChar;
begin
  New(ip);
  ip := '';
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_LOCAL_IP, @ip));
  Result := ip;
end;

function THTTPResponse.TInfo.LocalPort : Word;
var
  port : Longint;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_LOCAL_PORT, @port));
  Result := port;
end;

function THTTPResponse.TInfo.LastSocket : curl_socket_t;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_LASTSOCKET, @Result));
end;

function THTTPResponse.TInfo.ActiveSocket : curl_socket_t;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_ACTIVESOCKET, @Result));
end;

function THTTPResponse.TInfo.UserData : Pointer;
var
  data : PPChar = nil;
begin
  FErrors^.Push(curl_easy_getinfo(FCurl, CURLINFO_PRIVATE, data));
  if data <> nil then
    Result := data^
  else
    Result := nil;
end;

end.
