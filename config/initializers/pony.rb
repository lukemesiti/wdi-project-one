Pony.options = {
    :to => 'threethreesapp@gmail.com',
    :via => :smtp,
    :via_options => {
        :address                => 'smtp.gmail.com',
        :port                   => '587',
        :enable_startls_auto    => true,
        :user_name              => 'threethreesapp',
        :password               => 'Welcome12#',
        :authentication         => :plain,
        :domain                 => "localhost.localdomain"
    }
}


