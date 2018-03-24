:- module profile.


:- interface.

:- import_module
    getopt,
    map.

:- pred adjust_options_with_profile(option_ops(O)::in(option_ops),
    O::in, map(string, string)::in, option_table(O)::in,
    maybe_option_table(O)::out, string::out) is det.

:- implementation.

:- import_module
    list,
    map,
    string.

adjust_options_with_profile(OptOps, ProfileOpt, Profiles, OptT0,
    MaybeOptT, MmcOpts) :-
    getopt.lookup_string_option(OptT0, ProfileOpt, ProfileName),
    ( if
         map.search(Profiles, ProfileName, ProfileValue)
      then
         parse_args_str(OptOps, ProfileValue, MaybeOptTFromProfile0, MmcOpts0),
         (
           MaybeOptTFromProfile0 = ok(OptTFromProfile0),
           getopt.lookup_string_option(OptTFromProfile0, ProfileOpt,
               ProfileInProfileName),

          % stop recursively parsing if all profiles in ProfileValue
          % have already been handled
           ( if
                ProfileName = ProfileInProfileName
             then
                MaybeOptT = ok(combine_opt_tables(OptT0, OptTFromProfile0)),
                MmcOpts = MmcOpts0
             else
                adjust_options_with_profile(OptOps, ProfileOpt, Profiles,
                    OptTFromProfile0, MaybeOptTFromProfile, MmcOptsFromProfile),
                (
                  MaybeOptTFromProfile = ok(OptTFromProfile),
                  MaybeOptT = ok(combine_opt_tables(OptT0, OptTFromProfile)),
                  MmcOpts = MmcOpts0 ++ " " ++ MmcOptsFromProfile
                ;
                  MaybeOptTFromProfile = error(_),
                  MaybeOptT = MaybeOptTFromProfile,
                  MmcOpts = ""
               )
          )
         ;
           MaybeOptTFromProfile0 = error(_),
           MaybeOptT = MaybeOptTFromProfile0,
           MmcOpts = ""
         )
     else
         ErrorMsg = string.format(
             "Profile %s not found in config.", [s(ProfileName)]),
         MaybeOptT = error(ErrorMsg),
         MmcOpts = ""
    ).

:- pred parse_args_str(option_ops(O)::in(option_ops), string::in,
    maybe_option_table(O)::out, string::out) is det.
parse_args_str(OptionOps, AllArgs, MaybeOptTable, MmcOpts) :-
    { MerchantArgs, MmcOpts } =
        ( if string.split_at_string("-- ", AllArgs) = [Merchant, Mmc]
          then { Merchant, Mmc }
          else { AllArgs, " "}
        ),
    getopt.process_options(OptionOps, words(MerchantArgs), _, MaybeOptTable).

:- func combine_opt_tables(option_table(A), option_table(A)) = option_table(A).
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
            T1, T2).
