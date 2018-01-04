require 'rails_helper'

RSpec.describe "Api::V1::Questions", type: :request do
  describe 'POST /questions' do
    context 'with the invalid authentication headers' do
      it_behaves_like :deny_without_authorization, :post, '/api/v1/questions'
    end

    context 'with the valid authentication headers' do
      before do
        @user = create(:user)
      end

      context 'and with the valid params' do
        before do
          @form = create(:form, user: @user)
          @question_attributes = attributes_for(:question)
          post '/api/v1/questions', params: {question: @question_attributes, form_id: @form.id}, headers: header_with_authentication(@user)
        end

        it 'returns status 200' do
          expect_status(200)
        end

        it 'question are created with correct data' do
          @question_attributes.each do |field|
            expect(Question.first[field.first]).to eql(field.last)
          end
        end

        it 'returned data is correct' do
          @question_attributes.each do |field|
            expect(json[field.first.to_s]).to eql(field.last)
          end
        end
      end

      context 'and with invalid params' do
        before do
          @other_user = create(:user)
        end

        context 'valid form' do
          before do
            @form = create(:form, user: @user)
          end

          it 'returns status 400' do
            post '/api/v1/questions', params: { question: {}, form_id: @form.id },
                                      headers: header_with_authentication(@user)
            expect_status(400)
          end
        end

        context 'invalid form' do
          it 'returns status 404' do
            post '/api/v1/questions', params: { question: {} },
                                      headers: header_with_authentication(@user)
            expect_status(404)
          end
        end
      end
    end
  end

  describe 'PUT /questions/:id' do
    context 'with the invalid authentication headers' do
      it_behaves_like :deny_without_authorization, :put, '/api/v1/questions/8'
    end

    context 'with the valid authentication headers' do
      before do
        @user = create(:user)
      end

      context 'when the question exists' do
        context 'and the user is the form owner' do
          before do
            @form = create(:form, user: @user)
            @question = create(:question, form: @form)
            @question_attributes = attributes_for(:question, id: @question.id)
            put "/api/v1/questions/#{@question.id}",
                params: { question: @question_attributes },
                headers: header_with_authentication(@user)
          end

          it 'returns status 200' do
            expect_status(200)
          end

          it 'questions are updated with correct data' do
            @question.reload
            @question_attributes.each do |field|
              expect(@question[field.first]).to eql(field.last)
            end
          end

          it 'returned data is correct' do
            @question_attributes.each do |field|
              expect(json[field.first.to_s]).to eql(field.last)
            end
          end
        end

        context 'and the user is not the form owner' do
          before do
            @question = create(:question)
            @question_attributes = attributes_for(:question, id: @question.id)
            put "/api/v1/questions/#{@question.id}",
                params: { question: @question_attributes },
                headers: header_with_authentication(@user)
          end

          it 'returns 403' do
            expect_status(403)
          end
        end
      end

      context 'when the question dont exist' do
        before do
          @question_attributes = attributes_for(:question)
        end

        it 'retuns status 404' do
          delete '/api/v1/questions/0',
            params: { questions: @question_attributes },
            headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end

  describe 'DELETE /questions/:id' do
    before do
      @user = create(:user)
    end

    context 'with the invalid authentication headers' do
      context 'when the question exists' do
        context 'and the user is the form owner' do
          before do
            @form = create(:form, user: @user)
            @question = create(:question, form: @form)
            delete "/api/v1/questions/#{@question.id}",
                params: {},
                headers: header_with_authentication(@user)
          end

          it 'returns status 200' do
            expect_status(200)
          end

          it 'question are deleted' do
            expect(Question.all.count).to eql(0)
          end
        end

        context 'and the user is not the form owner' do
          before do
            @question = create(:question)
            delete "/api/v1/questions/#{@question.id}",
                params: {},
                headers: header_with_authentication(@user)
          end

          it 'returns status 403' do
            expect_status(403)
          end
        end
      end

      context 'when the question does not exist' do
        it 'retuns status 404' do
          delete '/api/v1/questions/0',
              params: {},
              headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end
end
