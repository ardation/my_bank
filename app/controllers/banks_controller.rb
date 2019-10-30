class BanksController < ApplicationController
  before_action :authenticate_user!
  decorates_assigned :banks, :bank
  breadcrumb 'Banks', :banks_path

  def index
    load_banks
    redirect_to bank_path(@banks.first) if @banks.count == 1
    redirect_to new_bank_path if @banks.empty?
  end

  def show
    load_bank
    redirect_to bank_accounts_path(@bank)
  end

  def new
    build_bank
    breadcrumb 'New', new_bank_path
  end

  def create
    build_bank
    save_bank || (new && render('new'))
  end

  def edit
    load_bank
    build_bank
    breadcrumb bank.name, bank_path(bank)
    breadcrumb 'Edit', edit_bank_path(bank)
  end

  def update
    load_bank
    build_bank
    save_bank || (edit && render('edit'))
  end

  def destroy
    load_bank
    @bank.destroy
    redirect_to banks_path
    flash[:warning] = 'Bank Connection deleted successfully.'
  end

  def sync
    load_bank
    if @bank.locked_at.present?
      flash[:warning] = 'Sync already in progress.'
    else
      @bank.perform_sync
      flash[:success] = 'Sync will begin shortly.'
    end
    redirect_to bank_accounts_path(@bank)
  end

  protected

  def load_banks
    @banks ||= bank_scope.page params[:page]
  end

  def load_bank
    @bank ||= bank_scope.find(params[:bank_id] || params[:id])
  end

  def build_bank
    @bank ||= bank_scope.build
    @bank.attributes = bank_params
  end

  def save_bank
    return false unless @bank.save

    redirect_to bank_path(@bank)
    flash[:success] = 'Bank Connection saved successfully. Sync will begin shortly.'
    true
  end

  def bank_params
    bank_params = params[:bank]
    bank_params ? bank_params.permit(:username, :password, :type) : {}
  end

  def bank_scope
    current_user.banks
  end
end
