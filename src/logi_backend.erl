%% @copyright 2014 Takeru Ohta <phjgt308@gmail.com>
%%
%% @doc バックエンドモジュールのインタフェース定義 および バックエンドオブジェクト操作関数を提供
-module(logi_backend).

%%------------------------------------------------------------------------------------------------------------------------
%% Behaviour Callbacks
%%------------------------------------------------------------------------------------------------------------------------
-callback format(logi:backend(), logi:msg_info(), logi:location(), io:format(), [term()]) -> iodata().
-callback write(logi:backend(), iodata()) -> ok | {error, Reason::term()}.

%%------------------------------------------------------------------------------------------------------------------------
%% Exported API
%%------------------------------------------------------------------------------------------------------------------------
-export([
         make/1, make/3, make/4,
         update/2,
         is_backend/1,
         get_id/1,
         get_ref/1,
         get_module/1,
         get_data/1
        ]).

-export_type([
              backend/0,
              spec/0,
              id/0,
              ref/0, % TODO: rename: serve
              data/0
             ]).

%%------------------------------------------------------------------------------------------------------------------------
%% Macros & Records & Types
%%------------------------------------------------------------------------------------------------------------------------
-define(BACKEND, ?MODULE).

-record(?BACKEND,
        {
          id     :: logi:backend_id(),
          ref    :: logi:backend_ref(),
          module :: module(),
          data   :: logi:backend_data()
        }).

-opaque backend() :: #?BACKEND{}.

-type spec() :: {ref(), module(), data()}
              | {id(), ref(), module(), data()}.

-type id() :: term().
-type ref() :: pid() | atom(). %% TODO: {via, ...}, {global, ...}
-type data() :: term().

%%------------------------------------------------------------------------------------------------------------------------
%% Exported Functions
%%------------------------------------------------------------------------------------------------------------------------
%% @equiv make(Ref, Ref, Module, Data)
-spec make(logi:backend_ref(), module(), logi:backend_data()) -> backend().
make(Ref, Module, Data) ->
    make(Ref, Ref, Module, Data). % TODO: delete

%% @doc バックエンドオブジェクトを生成する
-spec make(logi:backend_id(), logi:backend_ref(), module(), logi:backend_data()) -> backend().
make(Id, Ref, Module, Data) ->
    case is_backend_ref(Ref) andalso is_atom(Module) of
        false -> error(badarg, [Id, Ref, Module, Data]);
        true  ->
            #?BACKEND{
                id     = Id,
                ref    = Ref,
                module = Module,
                data   = Data
               }
    end.

%% @doc spec()をもとにbackend()を生成する
-spec make(spec()) -> backend().
make({Ref, Module, Data})     -> make(Ref, Ref, Module, Data);
make({Id, Ref, Module, Data}) -> make(Id, Ref, Module, Data);
make(Arg)                     -> error(badrag, [Arg]).

%% @doc バックエンドオブジェクトを更新する
-spec update(UpdateList, backend()) -> backend() when
      UpdateList  :: [UpdateEntry],
      UpdateEntry :: {id, logi:backend_id()} | {ref, logi:backend_ref()} | {module, module()} | {data, logi:backend_data()}.
update(UpdateList, #?BACKEND{} = Backend) when is_list(UpdateList) ->
    make(logi_util_assoc:fetch(id, UpdateList, Backend#?BACKEND.id),
         logi_util_assoc:fetch(ref, UpdateList, Backend#?BACKEND.ref),
         logi_util_assoc:fetch(module, UpdateList, Backend#?BACKEND.module),
         logi_util_assoc:fetch(data, UpdateList, Backend#?BACKEND.data));
update(UpdateList, Backend) -> error(badarg, [UpdateList, Backend]).

%% @doc 引数の値がbackend()型かどうかを判定する
-spec is_backend(backend() | term()) -> boolean().
is_backend(X) -> is_record(X, ?BACKEND).

%% @doc バックエンドのIDを取得する
-spec get_id(backend()) ->  logi:backend_id().
get_id(#?BACKEND{id = Id}) -> Id.

%% @doc バックエンドプロセスへの参照を取得する
-spec get_ref(backend()) -> logi:backend_ref().
get_ref(#?BACKEND{ref = Ref}) -> Ref.

%% @doc バックエンドのモジュールを取得する
-spec get_module(backend()) -> module().
get_module(#?BACKEND{module = Module}) -> Module.

%% @doc バックエンドに紐付く任意データを取得する
-spec get_data(backend()) -> logi:backend_data().
get_data(#?BACKEND{data = Data}) -> Data.

%%------------------------------------------------------------------------------------------------------------------------
%% Internal Functions
%%------------------------------------------------------------------------------------------------------------------------
-spec is_backend_ref(logi:backend_ref() | term()) -> boolean().
is_backend_ref(Ref) -> is_atom(Ref) orelse is_pid(Ref).
