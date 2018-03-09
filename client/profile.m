:- module profile.


:- interface.

:- import_module
    getopt,
    map.

:- pred special_handler(map(string, string)::in, OptType::in, OptType::in,
    OptType::in, special_data::in, option_table(OptType)::in,
    maybe_option_table(OptType)::out) is semidet.


:- implementation.

:- import_module
    list,
    map,
    string.

/*:- func combine_opt_tables(option_table(A), option_table(A)) = option_table(A).
combine_opt_tables(T1, T2) =
    map.foldl(
        (func(K, V1, A) =
            ( if  V2 = map.search(A, K),
                  V1 = accumulating(Vals1),
                  V2 = accumulating(Vals2)
              then
                  map.set(A, K, accumulating(Vals1 ++ Vals2))
              else
                  A
            )),
            T1, T2).*/

special_handler(Profiles, Prof, MmcOpt,
    Prof, string(Profile), OptTable0, MaybeOptTable) :-
    (
     if
         map.search(Profiles, Profile, ProfVal)
     then
         OptTable = map.det_transform_value(
             (func(V) = ( if V = accumulating(Vs)
                          then accumulating(Vs ++ [ProfVal | Vs])
                          else accumulating([ProfVal])
                        )),
             MmcOpt, OptTable0),
         MaybeOptTable = ok(OptTable)
         /*OptionOps = option_ops_multi(short_option, long_option,
            option_default, special_handler(Config)),
         getopt.process_options(OptionOps, [],
             _, MaybeOptTable1),
         (
           MaybeOptTable1 = ok(OptTable1),
           OptTable = combine_opt_tables(OptTable0, OptTable1),
           MaybeOptTable = ok(OptTable)
         ;
           MaybeOptTable1 = error(_),
           MaybeOptTable = MaybeOptTable1
         )*/
     else
         ErrorMsg = string.format(
             "Profile %s not found in config.", [s(Profile)]),
         MaybeOptTable = error(ErrorMsg)
    ).

