-module(erlcfg_schema_analyser2).
-export([analyse/2]).
-include("schema.hrl").

% The purpose of this stage is to ensure that we are not using any types in the
% schema definition that we have not defined, and then to generate a  node address
% to type mapping which looks like:
%
% [
%    {node1.intkey1, #validator{name=integer, 
%                               test=fun is_integer/1}
%    },
%    {node1.stringkey1, #validator{name=string, 
%                                  test=fun is_binary/1}
%    },
%    {node2.intkey2, #validator{name=integer, 
%                               test=fun is_integer/1}
%    },
%    {node2.stringkey2, #validator{name=string, 
%                                  test=fun is_binary/1}
%    },
%    {truefalse, #validator{name=boolean, 
%                           test=fun is_boolean/1}
%    }
% ]


analyse([], _Types) ->
    [];
analyse([Head|Rest], Types) ->
    analyse(Head, Rest, [], [], Types).

analyse(Current, [], Scope, Accm, Types) ->
    process(Current, Scope, Accm, Types);
analyse(Current, [Head|Rest], Scope, Accm, Types) ->
    Accm0 = process(Current, Scope, Accm, Types),
    analyse(Head, Rest, Scope, Accm0, Types).

process(#block{name=Name,child=[Head|Rest]}, Scope, Accm, Types) ->
    Scope0 = [Name | Scope],
    analyse(Head, Rest, Scope0, Accm, Types);
process(#declaration{type=DeclaredType, name=Name}, Scope, Accm, Types) ->
    Scope0 = lists:reverse([Name|Scope]),
    Addr = node_addr:join(Scope0),

    case proplists:get_value(Addr, Accm) of
        undefined ->
            case proplists:get_value(DeclaredType, Types) of
                undefined ->
                    throw({unknown_type_used, Addr});
                Fun ->
                    [{Addr, Fun} | Accm]
            end;
        _Found ->
            throw({type_already_defined_in_scope, Addr})
    end;
process(_Other, _Scope, Accm, _Types) ->
    Accm.






