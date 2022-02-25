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
    UserStateTID = telegram_bot_logic_sup:tid(),
    ReplyMessage = case maps:get(<<"text">>, Message) of
        <<"/start">> ->
            delete_current_state(ChatId, UserStateTID),
            <<"Welcome to Recorder Bot!\nPlease use commands to use this bot.">>;
        <<"/recorder">> ->
            telegram_bot_logic_record:init(Update);
        <<"/contribute">> ->
            delete_current_state(ChatId, UserStateTID),
            <<"https://github.com/mossafaei/daan-recorder-bot">>;
        _ ->
            CurrentState = get_current_state(ChatId, UserStateTID),
            case CurrentState of
                [] -> 
                    <<"Please choose right command!">>;
                _ ->
                [{_, State}] = get_current_state(ChatId, UserStateTID),
                Next_state_func = element(2, State),
                Next_state_func(Update)
            end
    end,
    pe4kin:send_message(BotName, #{chat_id => ChatId, text => ReplyMessage}),
    {noreply, state}.


get_current_state(ChatId, UserStateTID) ->
    State = ets:lookup(UserStateTID, ChatId),
    State.

delete_current_state(ChatId, UserStateTID) ->
    ets:delete(UserStateTID, ChatId).