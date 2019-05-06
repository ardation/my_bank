ActiveAdmin.register Bank::Account::Link do
  permit_params :bank_account_id, :budget_account_id

  index do
    selectable_column
    id_column
    column :bank_account
    column :budget_account
    column :created_at
    actions
  end

  filter :bank_account
  filter :budget_account

  form do |f|
    f.inputs do
      f.input :bank_account
      f.input :budget_account
    end
    f.actions
  end

  action_item :sync, only: :index do
    link_to 'Sync ANZ with YNAB', sync_admin_bank_account_links_path
  end

  collection_action :sync do
    Anz::PullService.pull
    Ynab::PullService.pull
    Ynab::PushService.push
    redirect_to collection_path, notice: 'Sync completed successfully!'
  end
end
