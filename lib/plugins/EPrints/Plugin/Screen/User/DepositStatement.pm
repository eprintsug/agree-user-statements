=head1 NAME

EPrints::Plugin::Screen::User::DepositStatement

=cut

package EPrints::Plugin::Screen::User::DepositStatement;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	# submit is a null action
	$self->{actions} = [qw/ submit update /];

	return $self;
}

sub properties_from
{
	my( $self ) = @_;

#print STDERR "PROP_FROM: proc user\n";
#print STDERR $self->{processor}->{user}, "\n";

	$self->{processor}->{dataset} = $self->{repository}->dataset( "user" );

	if( EPrints::Utils::is_set( $self->{session}->param( "userid" ) ) ){
		$self->{processor}->{dataobjid} = $self->{session}->param( "userid" );
		$self->{processor}->{dataobj} = new EPrints::DataObj::User( $self->{session}, $self->{processor}->{userid} );
	} else {

		$self->{processor}->{dataobj} = $self->{session}->current_user;
		$self->{processor}->{dataobjid} = $self->{session}->current_user->get_id;

	}
#print STDERR "X2 PROP_FROM: proc user\n";
#print STDERR $self->{processor}->{user}, "\n";

#	if( !defined $self->{processor}->{user} )
#	{
#		$self->{processor}->{user} = $self->{session}->current_user;
#		$self->{processor}->{userid} = $self->{session}->current_user->get_id;
#	}

	# Check requested document is not already OA
	if( !defined $self->{processor}->{user} || !defined $self->{processor}->{dataobj} )
	{
		&_properties_error;
		return;
	}

	
	# save user?

	$self->{processor}->{deposit_statement_saved} = $self->{session}->param( "deposit_statement_saved" );

	$self->SUPER::properties_from;

}

sub _properties_error
{
	my( $self ) = @_;
	
	$self->{processor}->{screenid} = "Error";
	$self->{processor}->add_message( "error", $self->{session}->html_phrase( "general:bad_param" ) );
}

sub can_be_viewed
{
	my( $self ) = @_;

	return 0 if !defined $self->{session}->current_user;
	
	my $dep_st = $self->{session}->current_user->value( "deposit_statement" );
	return 0 if defined $dep_st && defined $self->{session}->config( "current_deposit_statement" ) && $dep_st eq $self->{session}->config( "current_deposit_statement" );
	
	return $self->{session}->current_user->allow( "user/view", $self->{session}->current_user );
}
# submit is a null action
sub allow_submit { return 1; }
sub action_submit {}

sub allow_update
{
	return 1;
}

sub action_update
{
	my( $self ) = @_;

	my $session = $self->{session};

	my $user = $self->{processor}->{dataobj};

	my $rc = $self->workflow->update_from_form( $self->{processor} );
	return if !$rc; # validation failed

#$self->{processor}->add_message( "error", $session->html_phrase( "general:email_failed" ) );
		
#	$self->{processor}->add_message( "message", $session->html_phrase( "request/ack_page", link => $session->render_link( $eprint->get_url ) ) );
	$self->{processor}->{deposit_statement_saved} =1;
	$self->{processor}->{screenid} = "FirstTool";
	
}

sub redirect_to_me_url
{
	my( $self ) = @_;

	my $url = $self->SUPER::redirect_to_me_url;
	if( defined $self->{processor}->{userid} )
	{
		$url.="&userid=".$self->{processor}->{userid};
	}
	if( defined $self->{processor}->{deposit_statement_saved} )
	{
		$url.="&deposit_statement_saved=".$self->{processor}->{deposit_statement_saved};
	}
	return $url;
} 

sub workflow
{
	my( $self ) = @_;

	return $self->{processor}->{workflow} ||= EPrints::Workflow->new(
			$self->{repository},
			"deposit_statement",
			item => $self->{processor}->{dataobj}
		);
}

sub render
{
	my( $self ) = @_;

	my $session = $self->{session};

	my $page = $session->make_doc_fragment();
	return $page if $self->{processor}->{deposit_statement_saved};

	my $user = $self->{processor}->{user};

	my $form = $self->render_form;
	$page->appendChild( $form );

	$form->appendChild( $session->render_hidden_field( "userid", $user->get_id ) );

	$form->appendChild( $self->workflow->render );

	$form->appendChild( $session->xhtml->action_button(
			update => $self->phrase( "update:button" ) #request:button
		) );

	return $page;
}

1;

