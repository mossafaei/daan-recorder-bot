%%%-------------------------------------------------------------------
%% @doc daan_recorder_bot public API
%% @end
%%%-------------------------------------------------------------------

-module(daan_recorder_bot_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    daan_recorder_bot_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
