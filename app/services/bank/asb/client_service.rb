class Bank::Asb::ClientService
  attr_reader :bank

  def initialize(bank)
    @bank = bank
    login
  end

  def logout
    # client.link(class: 'logout').click
    client.close
  end

  def accounts
    client.link(id: 'statements_link').click
    client.div(id: 'Request_AccountKey_container').ul.lis.map do |li|
      name = li.spans.last.inner_html
      client.div(id: 'Request_AccountKey_input').click
      client.li(id: li.id).click
      client.div(id: 'StatementLPExport').button(value: 'Export').click
      path = file_name
      path.present? ? [name, process_export(path)&.account] : nil
    end.compact
  end

  protected

  def client
    return @client if @client

    @client = Watir::Browser.new :chrome, headless: true, options: { args: ['window-size=1920,1080'] }

    bridge = @client.driver.send :bridge
    path = "/session/#{bridge.session_id}/chromium/send_command"
    params = { behavior: 'allow', downloadPath: download_directory.to_s }
    bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior', params: params)

    @client
  end

  def login
    client.goto('https://online.asb.co.nz/auth/')
    client.text_field(id: 'dUsername').set bank.username
    client.text_field(id: 'password').set bank.password
    client.button(id: 'loginBtn').click
  rescue StandardError
    raise Bank::AuthenticationError
  end

  def process_export(file_path)
    return unless File.exist?(file_path)

    content = OFX(File.read(file_path))
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
end
