require 'rubygems'
require 'json'

class QuotesController < ApplicationController
  before_action :set_quote, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session

  # GET /quotes
  # GET /quotes.json
  def index
    @quotes = Quote.all
  end

  # GET /quotes/1
  # GET /quotes/1.json
  def show
  end

  # GET /quotes/new
  def new
    @quote = Quote.new
  end

  # GET /quotes/1/edit
  def edit
  end

  # POST /quotes
  # POST /quotes.json
  def create
    text = quote_params[:text]

    if text == 'help' or text == ''
      json = { text: "Utilize o comando `/novaquotes` para salvar frases ou citações hilárias que aconteceram na Novatics.\nAlguns exemplos:\n•`/novaquotes` Só sei que nada sei.\n•`/novaquotes` Com grandes poderes vem grandes responsabilidades.\n\nPara abrir este menu de ajuda, use `/novaquotes help`.\nPara ver todas as frases salvas: http://novaquote.herokuapp.com" }
      respond_to { |format| format.json { render json: json, status: :ok, location: @quote } }
      return
    end

    begin
      user = get_user_profile(quote_params)
    rescue Exception => e
      json = { text: "Ocorreu um erro: #{e.message}" }
      respond_to { |format| format.json { render json: json, status: :ok, location: @quote } }
      return
    end

    phrase = text.capitalize
    @quote = Quote.new(author: user['real_name'], message: phrase, image: user['image_32'])

    respond_to do |format|
      if @quote.save
        format.html { redirect_to @quote, notice: 'Frase adicionada com sucesso.' }

        json = {
          text: "Frase adicionada: #{phrase}.",
          attachments: [{
            title: "Ver todas as frases",
            title_link: "http://novaquote.herokuapp.com",
          }]
        }
        format.json { render json: json, status: :ok, location: @quote }
      else
        format.html { render :new }
        format.json { render json: @quote.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /quotes/1
  # PATCH/PUT /quotes/1.json
  def update
    respond_to do |format|
      if @quote.update(quote_params)
        format.html { redirect_to @quote, notice: 'Frase atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @quote }
      else
        format.html { render :edit }
        format.json { render json: @quote.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quotes/1
  # DELETE /quotes/1.json
  def destroy
    @quote.destroy
    respond_to do |format|
      format.html { redirect_to quotes_url, notice: 'Frase apagada' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_quote
      @quote = Quote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def quote_params
      params.permit!
    end

    def get_user_profile(params)
      client = HTTPClient.new
      token = 'xoxp-72060886741-72051010868-73339716976-8d6ea2a87f'
      user = params[:user_id]
      url = "https://slack.com/api/users.profile.get?token=#{token}&user=#{user}"
      str = client.get_content(url)
      response = JSON.parse(str)
      raise response['error'] if not response['ok']
      profile = response['profile']
    end
end
