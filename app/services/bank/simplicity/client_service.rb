class Bank::Simplicity::ClientService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
    login
  end

  def logout
    client.goto('https://app.simplicity.kiwi/login/logout')
    client.close
  end

  def transactions
    client.goto('https://app.simplicity.kiwi/api/download_transactions_report')
    process_export(file_name)
  end

  def unit_price
    return @unit_price if @unit_price

    client.goto('https://app.simplicity.kiwi/api/refreshBreakdown')
    @unit_price = JSON.parse(client.body.text)['since_breakdown']['price']
  end

  protected

  def client
    return @client if @client

    @client = Watir::Browser.new :chrome, options: { args: ['window-size=1920,1080'] }, headless: true

    bridge = @client.driver.send :bridge
    path = "/session/#{bridge.session_id}/chromium/send_command"
    params = { behavior: 'allow', downloadPath: download_directory.to_s }
    bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior', params: params)

    @client.goto('https://apisimplicity.mmcnz.co.nz/')
    @client.cookies.clear
    bank.session&.each do |cookie|
      @client.cookies.add cookie['name'], cookie['value'], cookie.except('name', 'value')
    end
    @client
  end

  def login
    client.goto('https://apisimplicity.mmcnz.co.nz/')
    return unless client.title == 'Login - Simplicity API'

    client.text_field(id: 'Username').set bank.username
    client.text_field(id: 'Password').set bank.password
    client.button(name: 'LogOn').click
    bank.update_attribute(:session, client.cookies.to_a) # rubocop:disable Rails/SkipsModelValidations
  rescue StandardError => e
    Rollbar.error(e)
    raise Bank::AuthenticationError
  end

  def process_export(file_path)
    return unless File.exist?(file_path)

    content = CSV.parse(File.read(file_path), headers: true)
    File.delete(file_path)
    content
  end

  def download_directory
    return @download_directory if @download_directory

    @download_directory = Rails.root.join('tmp', 'downloads')
    FileUtils.mkdir_p @download_directory
    @download_directory
  end

  def file_name
    30.times do
      files = Dir.glob(download_directory.join('*'))
      return files.first if files.present?
      return if client.td(class: 'infoMessageTextError').exists?

      sleep 1
    end
    nil
  end

  def complete_recaptcha; end
end
