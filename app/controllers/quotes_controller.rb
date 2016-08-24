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
    author = text.split[0].titlecase
    phrase = text.split[1..-1].join(' ').capitalize
    @quote = Quote.new(author: author, message: phrase)

    respond_to do |format|
      if @quote.save
        format.html { redirect_to @quote, notice: 'Frase adicionada com sucesso.' }

        msg = sprintf('Frase adicionada: "%s". Dita por %s', phrase, author)
        json = {
          text: msg,
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
      params.permit(:text)
    end
end
