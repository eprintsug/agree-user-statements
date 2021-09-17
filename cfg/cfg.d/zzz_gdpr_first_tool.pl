# Display different first tool for some users.
$c->{plugins}->{"Screen::FirstTool"}->{params}->{default} = sub {
	my( $screen ) = @_;

	my $user = $screen->{session}->current_user;
	return if !defined $user;

	#my @screens =  qw( Items Review User::View ); #normal defaults
	my @screens =  qw( WreoWelcome Items::WreoItems Items User::View ); #wreo redesign additions
	#if( $user->get_value( "username" ) eq "admin" ){
	
	my $utype = $user->get_value( "usertype" );
	if( $utype eq "user" )
	{
		unshift( @screens, 'User::DepositStatement' );
	} 
	elsif( $utype eq "admin" )
	{
		unshift( @screens, 'Admin' );
	}
	elsif( $utype eq "editor" )
	{
		unshift( @screens, 'Review' );
	}
	elsif( $utype eq 'sheffield_ethos' || $utype eq 'york_ethos' || $utype eq 'leeds_research_office' )
	{
		unshift( @screens, 'Items' );
	}

	my $screenid;
	for( @screens )
	{
		$screenid = $_;
		my $firstscreen = $screen->{session}->plugin( "Screen::$screenid",
			processor => $screen->{processor},
		);
		next if !defined $firstscreen;
		undef $screenid if !$firstscreen->can_be_viewed;
		last if $screenid;
	}

	return $screenid;
};

