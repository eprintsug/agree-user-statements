#################################
#
# These additions have been made to support the GDPR 
#
#################################
$c->{current_deposit_statement} = "deposit_v1";
$c->{current_privacy_statement} = "data_privacy_v1";
$c->{current_request_statement} = "request_privacy_v1";


# Virtual field added to EPrint to allow setting of user value from EPrints workflow.
push @{$c->{fields}->{eprint}},
{
        name => "deposit_statement",
        type => "virtualnamedsetwithvalue",
	set_name => "user_agreements",
	required => 0,
	render_input => 'render_agree_to_statement',
	form_input_style => 'checkbox',
	get_value => sub
	{
		my( $field, $eprint ) = @_;
		# $field->{session}->current_user
		my $user = $eprint->get_user;

		if( defined $user && $user->{dataset}->has_field( "deposit_statement" ) ){
			return $user->value( "deposit_statement" );		
		}
	},
	set_value => sub
	{
		my( $field, $eprint, $value ) = @_;
		my $user = $eprint->get_user;
		if( defined $user && $user->{dataset}->has_field( "deposit_statement" ) ){
			$user->set_value( "deposit_statement", $value );
			$user->commit;
		}
	},
};



push @{$c->{fields}->{request}},
{
        name => "privacy_statement",
        type => "namedset",
	set_name => "user_agreements",
        required => 0,
	form_input_style => 'checkbox',
	render_input => 'render_agree_to_statement',
};


push @{$c->{fields}->{user}},
{
	name=>"last_login",
	type=>"bigint",
	required=>0,
	volatile=>1,
	show_in_html => 0,
},
{
        name => "privacy_statement",
        type => "namedset",
	set_name => "user_agreements",
        required => 0,
	form_input_style => 'checkbox',
	render_input => 'render_agree_to_statement',
	show_in_html => 0,
},
{
        name => "deposit_statement",
        type => "namedset",
	set_name => "user_agreements",
        required => 0,
	form_input_style => 'checkbox',
	render_input => 'render_agree_to_statement',
	show_in_html => 0,
},
{
        name => "agreed_statements",
        type => "compound",
	multiple => 1,
	fields => [
		{
			sub_name => 'agreement',
			type => 'namedset',
			set_name => 'user_agreements',
		},
		{
			sub_name => 'time',
			type => 'bigint', #similar to LoginTicket
		},
	],
	render_value => 'render_agreed_statements',
},
;

$c->{plugins}->{"InputForm::Component::Field::AgreeToStatement"}->{params}->{disable} = 0;
$c->{plugins}->{"Screen::User::DepositStatement"}->{params}->{disable} = 0;

$c->{render_agreed_statements} = sub
{
	my( $repo, $field, $value, $alllangs, $nolink, $object ) = @_;

	unless( EPrints::Utils::is_set( $value ) )
        {
		if( $field->{render_quiet} )
		{
			return $repo->make_doc_fragment;
		}
		else
		{
			# maybe should just return nothing
			return $repo->html_phrase( "lib/metafield:unspecified", fieldname => $field->render_name( $repo ) );
		}
	}

	my $ul = $repo->make_element( "ul" );

	foreach my $row ( @{$value} )
	{
		my $li = $repo->make_element( "li" );
		$li->appendChild( $repo->html_phrase( 
			$field->get_name."_render_li",
			'user_agreement' => $repo->html_phrase( "user_agreements_typename_".$row->{agreement} ),
			'time'=> $repo->make_text( EPrints::Time::human_time( $row->{time} ) )
		) );
		$ul->appendChild( $li );
	}
	
	return $ul;
};

$c->{render_agree_to_statement} = sub
{
	my( $field, $repo, $value, $dataset, $staff, $hidden_fields, $obj, $basename ) = @_;

	my $frag = $repo->make_doc_fragment;

	my $required = $field->get_property( "required" );

	my %settings;
	my $default = $value;
	$default = [ $value ] unless( $field->get_property( "multiple" ) );
	$default = [] if( !defined $value );

	my( $tags, $labels ) = $field->input_tags_and_labels( $repo, $obj );
	
	my $input_style = $field->get_property( "input_style" ); # MetaField::Set defaults to 'short'

	if( !$field->get_property( "multiple" ) && !$required ) 
	{
		# If it's not multiple and not required there 
		# must be a way to unselect it.
		$tags = [ "", @{$tags} ];
		my $unspec = EPrints::Utils::tree_to_utf8( $field->render_option( $repo, undef ) );
		$labels = { ""=>$unspec, %{$labels} };
	}

	# should only be one option at a time here.
	foreach my $opt ( @{$tags} )
	{
		my $div = $repo->make_element( "div" );

		my $full_statement_id = $field->{set_name}."_typename_".$opt.":full_statement";

		if( $repo->get_lang->has_phrase( $full_statement_id, $repo ) ){
			my $full_statement_div = $repo->make_element( "div", id=> "agree-statement-full" );
			$full_statement_div->appendChild( $repo->html_phrase( $full_statement_id ) );
			$div->appendChild( $full_statement_div );
		}

		my $label_div = $repo->make_element( "div", class => "agree-statement-input" );
		$div->appendChild( $label_div );

		my $label = $repo->make_element( "label", for=>$basename."_".$opt );
		$label_div->appendChild( $label );
		my $checked = undef;

		if( $field->{multiple} )
		{
			foreach( @{$default} )
			{
				$checked = "checked" if( $_ eq $opt );
			}
		}
		else
		{
			if( defined $default->[0] && $default->[0] eq $opt )
			{
				$checked = "checked";
			}
		}
		$label->appendChild( $repo->render_noenter_input_field(
			type => $field->{form_input_style},
			name => $basename,
			id => $basename."_".$opt,
			value => $opt,
			checked => $checked ) );

		$label->appendChild( $repo->html_phrase( "agree_to_statement", user_agreement=>$repo->make_text( $labels->{$opt} ) ) );
		$frag->appendChild( $div );

	}
	return $frag;
};

#################################
$c->add_dataset_trigger( 'loginticket', EPrints::Const::EP_TRIGGER_CREATED, sub
{
	my( %args ) = @_;
	my( $repo, $loginticket ) = @args{qw( repository dataobj )};

	# trigger is global - check that current repository 'user' dataset has last_login field to be updated
	return unless $repo->get_dataset( "user" )->has_field( "last_login" ); 

	#update volatile field in user record
	my $user = EPrints::DataObj::User->new( $repo, $loginticket->get_value( "userid" ) );
	if( defined $user ){
		$user->set_value( "last_login", $loginticket->get_value( "time" ) );
		$user->commit();
	}
}, priority => 100 );


$c->add_dataset_trigger( 'user', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub
{
        my( %args ) = @_;
        my( $repo, $user, $changed ) = @args{qw( repository dataobj changed )};

	my $a_s = $user->get_value( "agreed_statements" );
	my $new_as = 0;

	my @statement_fields = qw/ privacy_statement deposit_statement /;
	# If this is a new registration, then you can't call $user->set_value (on a compound
	#  field at least), as by this point the user doesn't have an ID.
	if( !defined $user->get_id ){
		# registration - before first commit
		foreach my $field( @statement_fields ){
			if( $user->is_set( $field ) ){
				my $as = $user->get_value( $field );
				if( !grep { $_->{agreement} eq $as } @{$a_s} ){
					push @{$a_s}, { agreement => $as, 'time' => time };
					$new_as++;
				}
			}
		}
		if( $new_as ){
			# pre-first commit. Add to data
			$user->{data}->{agreed_statements} = $a_s;
		}
	} else {
		foreach my $field( @statement_fields ){
			# NB $changed has the *old* values in.
			my $as = $user->get_value( $field );
			# check using 'exists' as previous value will be undef.
			if( exists $changed->{$field} && !grep { $_->{agreement} eq $as } @{$a_s} ){
				push @{$a_s}, { agreement => $as, 'time' => time };
				$new_as++;
			}
		}
		if( $new_as ){
			$user->set_value( "agreed_statements", $a_s );
		}
	}
}, priority => 101 );
