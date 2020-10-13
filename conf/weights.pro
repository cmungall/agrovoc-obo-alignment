% baseline
weight(2.0, [predicate_id='owl:equivalentClass']).

% OBO
weight(-3, [predicate_id='owl:equivalentClass', any_match_field='oio:hasNarrowSynonym']).
weight(-3, [predicate_id='owl:equivalentClass', any_match_field='oio:hasBroadSynonym']).
weight(-1, [predicate_id='owl:equivalentClass', any_match_field='oio:hasRelatedSynonym']).

weight(-3, [subject_source=sweet, object_source='ENVO', subject_category='property']).
weight(1, [subject_source=sweet, object_source='ENVO', subject_category='realm']).
weight(1, [subject_source=sweet, object_source='ENVO', subject_category='land region']).
weight(1, [subject_source=sweet, object_source='ENVO', subject_category='phenomena']).


weight(-0.5, [predicate_id='owl:equivalentClass', match_category='one_to_many']).
weight(-0.5, [predicate_id='owl:equivalentClass', match_category='many_to_one']).
weight(-1, [predicate_id='owl:equivalentClass', match_category='many_to_many']).


% pre-supplied mapping
weight(4,  [predicate_id='owl:equivalentClass', any_match_field='skos:exactMatch', any_match_field='schema:url']).
weight(-8, [predicate_id='owl:equivalentClass', any_match_field='skos:relatedMatch', any_match_field='schema:url']).
weight(2, [predicate_id='owl:equivalentClass', any_match_field='oio:hasDbXref', any_match_field='schema:url']).

% lexical is lower, stemmming even lower
weight(-1.0, [predicate_id='owl:equivalentClass', match_type=['Lexical','Stemming']]).
weight(-0.5, [predicate_id='owl:equivalentClass', match_type=['Lexical']]).

weight(-1, [match_string=S]) :-  atom_length(S,3).
weight(-2, [match_string=S]) :-  atom_length(S,2).
weight(-3, [match_string=S]) :-  atom_length(S,1).
weight(-99, [match_string=S]) :-  atom_length(S,0).

% reward multi-word terms
weight(W, [match_string=S]) :-  concat_atom(L,' ',S),length(L,Len),W is (Len-1) * 0.3.



