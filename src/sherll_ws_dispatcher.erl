-module(sherll_ws_dispatcher).
-behaviour(gen_server).

-include("../include/records.hrl").

-export([start_link/0,
         init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

start_link() ->
   gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
   {ok, undefined}.

handle_call({inbound_frame, Msg}, Req, State) ->
   {WebSocketPid, Reference} = Req,
   %% find recipient actor
   Actor = hd(ets:lookup(actor_list, shell)),
   %% pass Msg and From to recipient actor
   gen_server:cast(
      Actor#actor_list.module, 
      {do, Msg, WebSocketPid}
   ),
   {reply, ok, State};
handle_call({outbound_frame, Msg}, Req, State) ->
   {reply, {text, Msg}, Req, State};
handle_call(_Msg, _From, State) ->
   {reply, ok, State}.

handle_cast(_Msg, State) ->
   {noreply, State}.

handle_info(_Msg, State) ->
   {noreply, State}.

terminate(_Reason, _State) ->
   ok.

code_change(_OldVsn, State, _Extra) ->
   {ok, State}.