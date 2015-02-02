%%%-------------------------------------------------------------------
%%% @author Pedro Marques da Silva <pedro.silva@I.lan>
%%% @copyright (C) 2015, Pedro Marques da Silva
%%% @doc
%%%
%%% @end
%%% Created : 25 Jan 2015 by Pedro Marques da Silva <pedro.silva@I.lan>
%%%-------------------------------------------------------------------
-module(erldog_http).

-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([validate/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).


-define(DD_API_VERSION,"v1").
-define(SERVER, ?MODULE).

-record(state, {
	       		dd_scheme ,
				dd_host,
				dd_port,
				dd_path
	         }).

%%%===================================================================
%%% API
%%%===================================================================
%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


validate(APIKey) ->
	gen_server:call(?MODULE, {validate,APIKey}, 5000)
	.


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    {ok,DatadogScheme} = application:get_env(dd_scheme),
    {ok,DatadogHost} = application:get_env(dd_host),
	{ok,DatadogPort} = application:get_env(dd_port),
    {ok,DatadogPath} = application:get_env(dd_path),
	lager:info("Parameters: ~p, ~p , ~p, ~p",[DatadogScheme,DatadogHost,DatadogPort,DatadogPath]),


	{ok,Conn}= case catch shotgun:open(DatadogHost, DatadogPort,DatadogScheme) of 
			  {ok, Connection} -> 	%%monitor(process, Connection),
									lager:info("Get a connection from remote ~p",[Connection]),
									{ok, Connection}
									;
									Error -> lager:error("Error on open resource ~p",[Error]),
											 Error
	end,
	{ok, Response} = case shotgun:get(Conn, "/api/v1/validate?api_key=MY_API_KEY") of 
			{ok, Result} -> {ok, Result} ;
			Failed -> 
					lager:error("Failed to get  resource ~p",[Failed]),
					Failed
	end,
	io:format("~p~n", [Response]),	
	shotgun:close(Conn),
    {ok, #state{
				dd_scheme=DatadogScheme,
				dd_host=DatadogHost,
				dd_port=DatadogPort,
				dd_path=DatadogPath
				}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({validate, APIKey}, _From, State) ->	
	lager:info("Validate called for the APIKey: ~p",[APIKey]),
	Reply = ok,
    {reply, Reply, State};

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================