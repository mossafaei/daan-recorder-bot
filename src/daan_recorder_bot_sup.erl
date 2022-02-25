%%%-------------------------------------------------------------------
%% @doc daan_recorder_bot top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(daan_recorder_bot_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

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
    application:ensure_all_started(pe4kin),

    {_, BotName} = application:get_env(pe4kin, bot_name),
    {_, BotToken} = application:get_env(pe4kin, bot_token),
    pe4kin:launch_bot(BotName, BotToken, #{receiver => true}),

    SupFlags = #{strategy => one_for_one,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [
        #{
            id => telegram_bot_receiver_server_1,
            start => {telegram_bot_receiver_server, start_link, [#{bot_name => BotName}]},
            restart => permanent,
            shutdown => 5000,
            type => worker,
            modules => [telegram_bot_receiver_server]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions
