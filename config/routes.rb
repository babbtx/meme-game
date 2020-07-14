Rails.application.routes.draw do

  get '/', to: redirect('https://github.com/babbtx/meme-game')

  scope '/api/v1' do
    resources :answers, only: [:index, :show, :update]
    resources :games, only: [:create] do
      resources :answers, controller: 'game_answers', only: [:index, :create]
    end
    resources :users, param: :token_subject, constraints: {token_subject: /[^\/]+/}, only: [] do
      resources :answers, controller: 'user_answers', only: [:index, :show]
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
