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

unit curl.http.session.property_modules.http2;

{$mode objfpc}{$H+}
{$IFOPT D+}
  {$DEFINE DEBUG}
{$ENDIF}

interface

uses
  libpascurl, curl.session.property_module;

type
  TModuleHTTP2 = class(curl.session.property_module.TPropertyModule)
  public
    type
      TStreamWeight = 1 .. 256;
  protected
    { Set numerical stream weight. }
    procedure SetStreamWeight (AWeight : TStreamWeight); 
  public
    { Set numerical stream weight. 
      When using HTTP/2, this option sets the individual weight for this 
      particular stream used by the easy handle. }
    property StreamWeight : TStreamWeight write SetStreamWeight default 16;   
  end;

implementation

{ TModuleHTTP2 }

procedure TModuleHTTP2.SetStreamWeight (AWeight : TStreamWeight);
begin
  Option(CURLOPT_STREAM_WEIGHT, Longint(AWeight));
end;

end.
