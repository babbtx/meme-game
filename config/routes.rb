Rails.application.routes.draw do

  scope '/api/v1' do
    resources :answers, only: [:index, :show, :update]
    resources :users, param: :token_subject, only: [] do
      resources :answers, controller: 'user_answers', only: [:index]
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
