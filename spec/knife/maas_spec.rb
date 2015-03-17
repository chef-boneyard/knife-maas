require 'spec_helper'

describe Chef::Knife::Maas do
  it 'has a version number' do
    expect(Chef::Knife::Maas::VERSION).not_to be nil
  end

  it 'does nothing useful' do
    expect(true).to eq(true)
  end
end
