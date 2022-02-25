%%%-------------------------------------------------------------------
%% @doc telegram_bot_logic_sup top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(telegram_bot_logic_sup).

-behaviour(supervisor).

-export([
    start_link/0, 
    send_message_to_worker/3,
    tid/0
]).

-export([init/1]).

-define(SERVER, ?MODULE).
-define(WORKER, telegram_bot_logic_server).
-define(ETS_TABLE_NAME, user_states).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

send_message_to_worker(BotName, Update, SupRef) ->
    #{<<"message">> := #{<<"chat">> := #{<<"id">> := ChatId}} = _} = Update,
    ChildrenSize = supervisor:count_children(SupRef),
    {active, ActiveSize} = lists:nth(2, ChildrenSize),
    Id = (ChatId rem ActiveSize) + 1,
    gen_server:cast(list_to_atom(lists:concat([?WORKER, Id])), {send_response_to_user, BotName, Update}).

tid() ->
    ?ETS_TABLE_NAME.

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    {_, Number} = application:get_env(daan_recorder_bot, num_logic_server),
    {_, BotName} = application:get_env(pe4kin, bot_name),
    ets:new(?ETS_TABLE_NAME, [public, named_table]),

    SupFlags = #{strategy => one_for_one,
                 intensity => 0,
                 period => 1},
    ChildSpecs = create_child_specs(Number, BotName),
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

create_child_specs(Number, BotName) ->
    [#{
        id => {telegram_bot_logic_server, X}, 
        start => {telegram_bot_logic_server, start_link, [#{id => X}]},
        restart => permanent,
        shutdown => 5000,
        type => worker,
        modules => [telegram_bot_logic_server]
     } || 
    X <- lists:seq(1, Number)].