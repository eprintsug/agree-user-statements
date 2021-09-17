package EPrints::Plugin::InputForm::Component::Field::AgreeToStatement;

use EPrints::Plugin::InputForm::Component::Field;
@ISA = ( "EPrints::Plugin::InputForm::Component::Field" );

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );
	
	$self->{name} = "Agree to Statement";
	$self->{visible} = "all";
	#$self->{visdepth} = 1;
	return $self;
}

sub render_title
{
	my( $self, $surround ) = @_;
	if ($self->{config}->{title})
	{
		return $self->{config}->{title};
	}
	return $self->{config}->{field}->render_name( $self->{session} );
}

sub render_content
{
	my( $self, $surround ) = @_;

	my $frag = $self->{session}->make_doc_fragment;
	my $div = $self->{session}->make_element( "div", class => "agree-statement" );
	$frag->appendChild( $div );
	
	# If this is being rendered with surround="None" or surround="Light", include the title in here.
	if( $surround->{id} ne "InputForm::Surround::Default" ){
		my $title_div = $self->{session}->make_element( "div", class => "agree-statement-title" );
		$title_div->appendChild( $self->render_title );

		$div->appendChild( $title_div );
	}

	# phrase for all AgreeToStatement fields
	# phraseid: Plugin/InputForm/Component/Field/AgreeToStatement:intro
	if( $self->{session}->get_lang->has_phrase( $self->html_phrase_id( "intro" ) ) ){
		my $intro_div = $self->{session}->make_element( "div", class => "agree-statement-intro" );
		$intro_div->appendChild( $self->html_phrase( "intro" ) );
		$div->appendChild( $intro_div );
	}

	# field specific intro
	# phraseid e.g. user_fieldname_deposit_statement:intro
	my $field_intro_phraseid = $self->{config}->{field}->{confid}."_fieldname_".$self->{config}->{field}->{name}.':intro';
	if( $self->{session}->get_lang->has_phrase( $field_intro_phraseid  ) ){
		my $intro_div = $self->{session}->make_element( "div", class => "agree-statement-intro" );
		$intro_div->appendChild( $self->{session}->html_phrase( $field_intro_phraseid  ) );
		$div->appendChild( $intro_div );
	}

	my $field_div = $self->{session}->make_element( "div", class=>"agree-statement-field", id=>"agree-statement-field" );
	$div->appendChild( $field_div );


	my $value;
        if( $self->{dataobj} )
	{
		$value = $self->{dataobj}->get_value( $self->{config}->{field}->{name} );
	}
	else
	{
		$value = $self->{default};
	}

	$field_div->appendChild( $self->{config}->{field}->render_input_field(
		$self->{session},
		$value,
		$self->{dataobj}->get_dataset,
		0, # staff mode should be detected from workflow
		undef,
		$self->{dataobj},
		$self->{prefix},
	) );

	$div->appendChild( $self->{session}->make_element( "script", src=>"/javascript/jquery.modal.min.js" ) );
	$div->appendChild( $self->{session}->make_element( "link",
                        rel => "stylesheet",
                        type => "text/css",
			href => "/style/jquery.modal.min.css",
                ) );
	$div->appendChild( $self->{session}->make_element( "script", src=>"/javascript/jquery.agree_to_statement.js" ) );

#	$div->appendChild( $self->{session}->make_javascript( <<EOJ ) );
#//new Component_Field_PrivacyStatement ('$self->{prefix}');
#EOJ

	if( $self->{session}->get_lang->has_phrase( $self->html_phrase_id( "style" ) ) ){
		$div->appendChild( $self->html_phrase( "style" ) );
	}
	return $frag;
}

1;
