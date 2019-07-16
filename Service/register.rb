# app\services\companies\register.rb

class Companies::Register
  attr_accessor :company

  # 初期化
  # @param [Object] company 会社情報
  def initialize(company = nil)
    @company = company
  end

  # 会社登録
  # @param [Hash] request 入力データ(会社モデル)
  # @return [Object] company 会社情報
  # @raise [ActiveRecord::StatementInvalid] DBアクセス時に何らかのエラー情報
  # @raise [ValidationError] バリデーションエラー
  def insert(request)
    @company = ::Company.new(request)
    @company.save!

    @company
  end

  # 会社更新
  # @param [Hash] request 入力データ(会社モデル)
  # @option request [String] :updated_at 更新日時
  # @return [Object] company 会社情報
  # @raise [AlreadyUpdated] 更新されていた
  # @raise [AlreadyDeleted] 更新データなし(削除されていた)
  # @raise [ActiveRecord::StatementInvalid] DBアクセス時に何らかのエラー情報
  # @raise [ValidationError] バリデーションエラー
  def update(request)
    ActiveRecord::Base.transaction do
      @company.lock!
      fail AlreadyUpdated  if ::Company.already_updated?(request['updated_at'], @company)
      fail AlreadyDeleted  if ::Company.already_deleted?(@company)
      @company.update!(request)

      @company
    end
  end

  # 会社削除
  # @param [Hash] request 送信データ
  # @return [Object] company 会社情報
  # @raise [ActiveRecord::StatementInvalid] DBアクセス時に何らかのエラー
  # @raise [AlreadyDeleted] 更新データなし(削除されていた)
  # @raise [ActiveRecord::StatementInvalid] DBアクセス時に何らかのエラー情報
  # @raise [ValidationError] バリデーションエラー
  def delete(request)
    ActiveRecord::Base.transaction do
      fail AlreadyDeleted  if ::Company.already_deleted?(@company)
      @company.delete

      @company
    end
  end

end