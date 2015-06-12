require 'spec_helper'
describe 'ghost', :type => :class do

  ['Archlinux', 'RedHat', 'Debian'].each do |osfamily|
    context "on #{osfamily}" do
      let :facts do
        {
          :osfamily => "#{osfamily}",
        }
      end

      if osfamily == 'Archlinux'
        # So long as nodejs is included, it can handle it's own other-OS dependencies
        context 'with include_nodejs' do
          let(:params) { {'include_nodejs' => true } }
          it { should contain_class('nodejs') }
        end

        context 'without include_nodejs' do
          let(:params) { {'include_nodejs' => false } }
          it { should_not contain_class('nodejs') }
        end
      end

      context 'with defaults for all parameters' do
        it { should contain_class('ghost') }
        it { should contain_file('/srv/ghost').with_ensure('directory').with_owner('ghost').with_group('ghost') }
      end

    end
  end
end
