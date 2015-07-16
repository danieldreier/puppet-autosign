require 'spec_helper_acceptance'

describe 'autosign class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'autosign': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('autosign') do
      it { is_expected.to be_installed.by('gem') }
    end

  end
  context 'non-default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { ::autosign:
        ensure      => 'latest',
        journalpath => '/tmp/jwt_journal',
        settings    => {
          'general' => {
            'logfile' => '/tmp/autosign.log'
          },
          'jwt_token' => {
            'secret' => 'hunter2',
            'validity' => '3601',
          }
        }
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('autosign') do
      it { is_expected.to be_installed.by('gem') }
    end

    describe file('/etc/autosign.conf') do
      it { should be_file }
      it { should contain '[jwt_token]' }
      it { should contain 'hunter2' }
      it { should contain '/tmp/autosign.log' }
    end

    describe file('/tmp/jwt_journal') do
      it { should be_directory }
    end
  end

  context 'ensure absent' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { ::autosign:
        ensure => 'absent'
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('autosign') do
      it { is_expected.not_to be_installed }
    end

    describe file('/etc/autosign.conf') do
      it { is_expected.not_to exist }
    end
  end
end
