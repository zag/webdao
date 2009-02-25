package MyTest;
use WebDAO::Component;
use base 'WebDAO::Component';

sub fetch {
    my $self = shift;
    return "Simple text";
}
sub Menu {
    return <<MENU;
        <ul id="genmenu">    
            <li  title="Home" class="active">
              <a href="/page/Blogs" > Home</a>
            </li>    
            <li  title="Setup" >
               <a href="/page/Menu_personal" >Setup</a>
            </li>    
            <li  title="Admin" >
                <a href="/page/Admin_menu" >Admin</a>
            </li>
        </ul>
MENU
}
1;

