-module(telegram_bot_logic_server).

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
    handle_cast/2
    %handle_info/2
    %terminate/2,
    %code_change/3
]).

-define(SERVER, ?MODULE).

start_link(Args) ->
    Id = maps:get(id, Args),
    gen_server:start_link({local, list_to_atom(lists:concat([?SERVER, Id])) }, ?SERVER, Args, []).


init(Args) ->
    {ok, state}.

handle_cast({send_response_to_user, BotName, Update}, _) ->
    #{<<"message">> := #{<<"chat">> := #{<<"id">> := ChatId}} = Message} = Update,
    ReplyMessage = case maps:get(<<"text">>, Message) of
        <<"/donate">> -> 
            <<"google.com">>;
        _ ->
            <<"Other">>
    end,
    pe4kin:send_message(BotName, #{chat_id => ChatId, text => ReplyMessage}),
    {noreply, state}.
