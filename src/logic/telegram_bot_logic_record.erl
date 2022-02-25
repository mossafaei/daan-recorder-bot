-module(telegram_bot_logic_record).

-export([
    init/1,
    get_class_username/1,
    get_class_password/1
]).

-record(state, {
    next_function,
    message_flow = "/recorder" :: string(),
    class_username :: undefined | string(),
    class_password :: undefined | string()
}).

init(Update) ->
    #{<<"message">> := #{<<"chat">> := #{<<"id">> := ChatId}} = Message} = Update,
    UserStateTID = telegram_bot_logic_sup:tid(),
    State = #state{next_function = fun telegram_bot_logic_record:get_class_username/1},
    update_state(ChatId, UserStateTID, State),
    <<"Please send your class's username.">>.


get_class_username(Update) ->
    #{<<"message">> := #{<<"chat">> := #{<<"id">> := ChatId}} = Message} = Update,
    UserStateTID = telegram_bot_logic_sup:tid(),
    State = get_current_state(ChatId, UserStateTID),
    UpdatedState = State#state{class_username = Message, next_function = fun telegram_bot_logic_record:get_class_password/1},
    update_state(ChatId, UserStateTID, UpdatedState),
    <<"Please send your class's password.">>.


get_class_password(Update) ->
    #{<<"message">> := #{<<"chat">> := #{<<"id">> := ChatId}} = Message} = Update,
    UserStateTID = telegram_bot_logic_sup:tid(),
    delete_current_state(ChatId, UserStateTID),
    <<"Your class is going to record.">>.

get_current_state(ChatId, UserStateTID) ->
    [{_, State}] = ets:lookup(UserStateTID, ChatId),
    State.

update_state(ChatId, UserStateTID, State) ->
    ets:delete(UserStateTID, ChatId),
    ets:insert(UserStateTID, {ChatId, State}).

delete_current_state(ChatId, UserStateTID) ->
    ets:delete(UserStateTID, ChatId).