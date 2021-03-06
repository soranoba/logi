%% @copyright 2014 Takeru Ohta <phjgt308@gmail.com>
%%
%% @doc root supervisor module
%% @private
-module(logi_sup).

-behaviour(supervisor).

%%------------------------------------------------------------------------------------------------------------------------
%% Exported API
%%------------------------------------------------------------------------------------------------------------------------
-export([start_link/0]).

%%------------------------------------------------------------------------------------------------------------------------
%% 'supervisor' Callback API
%%------------------------------------------------------------------------------------------------------------------------
-export([init/1]).

%%------------------------------------------------------------------------------------------------------------------------
%% Macros
%%------------------------------------------------------------------------------------------------------------------------
-define(SUPERVISOR_CHILD(Module), {Module, {Module, start_link, []}, permanent, 5000, supervisor, [Module]}).

%%------------------------------------------------------------------------------------------------------------------------
%% Exported Functions
%%------------------------------------------------------------------------------------------------------------------------
%% @doc Starts root supervisor
-spec start_link() -> {ok, pid()} | {error, Reason::term()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%%------------------------------------------------------------------------------------------------------------------------
%% 'supervisor' Callback Functions
%%------------------------------------------------------------------------------------------------------------------------
%% @hidden
init([]) ->
    Children =
        [
         ?SUPERVISOR_CHILD(logi_backend_manager_sup)
        ],
    {ok, {{one_for_one, 5, 10}, Children}}.    
