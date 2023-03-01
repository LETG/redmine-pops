AccountController.class_eval do
  # def successful_authentication(user)
  #   logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
  #   # Valid user
  #   self.logged_user = user
  #   # generate a key and set cookie if autologin
  #   if params[:autologin] && Setting.autologin?
  #     set_autologin_cookie(user)
  #   end
  #   call_hook(:controller_account_success_authentication_after, {:user => user})
  #   byebug
  #   redirect_back_or_default root_path
  # end
end

module AccountControllerPatch
  def self.included(base)
    base.class_eval do
      def successful_authentication(user)
        logger.info "Successful authentication for '#{user.login}' from #{request.remote_ip} at #{Time.now.utc}"
        # Valid user
        self.logged_user = user
        # generate a key and set cookie if autologin
        if params[:autologin] && Setting.autologin?
          set_autologin_cookie(user)
        end
        call_hook(:controller_account_success_authentication_after, {:user => user})
        redirect_back_or_default home_path
      end
    end
  end
end

AccountController.send(:include, AccountControllerPatch)