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
    gen_server:start_link({local, ?SERVER}, ?SERVER, Args, [{hibernate_after, 5000}]).


init(Args) ->
    BotName = maps:get(bot_name, Args), 
    pe4kin_receiver:subscribe(BotName, self()),
    pe4kin_receiver:start_http_poll(BotName, #{limit=>100, timeout=>60}),
    {ok, state}.


handle_info({pe4kin_update, BotName, Upd}, State) ->
    io:format("~p", [Upd]),
    ChatId = maps:get(<<"id">>, maps:get(<<"chat">>, maps:get(<<"message">>, Upd))),
    pe4kin:send_message(BotName, #{chat_id => ChatId, text => <<"Hey What's up?">>}),
    {noreply, state}.
