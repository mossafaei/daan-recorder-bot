-module(telegram_bot_receiver_server).

-behaviour(gen_server).

-export([
    start_link/1
]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------
-export([
    init/1,
    %handle_call/3,
    %handle_cast/2,
    handle_info/2
    %terminate/2,
    %code_change/3
]).

-define(SERVER, ?MODULE).

start_link(Args) ->
    gen_server:start_link({local, ?SERVER}, ?SERVER, Args, []).


init(Args) ->
    {ok, SupRef} = telegram_bot_logic_sup:start_link(),
    BotName = maps:get(bot_name, Args),
    pe4kin_receiver:subscribe(BotName, self()),
    pe4kin_receiver:start_http_poll(BotName, #{limit=>100, timeout=>60}),
    {ok, #{supervisor_ref => SupRef}}.


handle_info({pe4kin_update, BotName, Upd}, State) ->
    telegram_bot_logic_sup:send_message_to_worker(BotName, Upd, maps:get(supervisor_ref, State)),
    {noreply, State}.
