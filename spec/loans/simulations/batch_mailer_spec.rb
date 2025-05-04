require 'rails_helper'

RSpec.describe Loans::Simulations::BatchMailer, type: :mailer do
  describe '#send_results' do
    let(:batch) { create(:simulation_batch, email: 'user@example.com') }
    let(:mail) { described_class.with(batch: batch).send_results }
    let!(:simulation_one) { create(:simulation, :with_result, simulation_batch: batch) }
    let!(:simulation_two) { create(:simulation, :with_result, simulation_batch: batch) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Your simulation batch is complete')
      expect(mail.to).to eq([batch.email])
      expect(mail.from).to eq(['from@example.com']) # ajuste se tiver um default_from diferente
    end

    it 'renders the body' do
      expect(mail.body.encoded).to include('Your Simulation Batch is Complete!')
    end

    it 'attaches the CSV file with correct name' do
      expect(mail.attachments.count).to eq(1)
      attachment = mail.attachments.first

      expect(attachment.filename).to eq("simulation_batch_#{batch.id}.csv")
    end

    it 'includes the simulations data in the CSV' do
      attachment = mail.attachments.first
      csv_content = attachment.body.decoded
      csv = CSV.parse(csv_content, headers: true)

      expect(csv.count).to eq(2)
      expect(csv.headers).to include('ID', 'Loan Amount')
      expect(csv['ID']).to include(simulation_one.id.to_s, simulation_two.id.to_s)
    end
  end
end
