package MyMenu;
use WebDAO;
use base 'WebDAO::Component';

#default no output
sub fetch { return }

#puplic method for write menu html
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

