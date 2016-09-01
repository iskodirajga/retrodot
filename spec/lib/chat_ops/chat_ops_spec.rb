RSpec.describe ChatOps do
  before do
    ChatOps.class_variable_set :@@commands, []
  end

  describe '.register' do
    it 'adds class to commands class variable' do
      Foo = Class.new

      ChatOps.register Foo

      expect(ChatOps.commands).to include Foo
    end
  end

  describe '.commands' do
    it 'returns an array object' do
      expect(ChatOps.commands).to be_an Array
    end

    it 'registers when some class inherits from ChatOpsCommand' do
      TestCommand1 = Class.new(ChatOpsCommand)
      TestCommand2 = Class.new(ChatOpsCommand)

      expect(ChatOps.commands).to include TestCommand1, TestCommand2
    end
  end

  describe '.matcher' do
    let(:cmd_1_class) { Class.new(ChatOpsCommand) }
    let(:cmd_2_class) { Class.new(ChatOpsCommand) }

    it 'builds a regex from defined commands' do
      cmd_1_class.class_eval { match /test_regex1_[0-9]+/ }
      cmd_2_class.class_eval { match /test_regex2_[a-z]+/ }

      expect(ChatOps.matcher).to match 'test_regex1_0123'
      expect(ChatOps.matcher).to match 'test_regex2_abcdef'
    end
  end

  describe '.process' do
    let(:cmd_1_class) { Class.new(ChatOpsCommand) }
    let(:cmd_2_class) { Class.new(ChatOpsCommand) }
    let!(:cmd_1_instance) { cmd_1_class.new }
    let!(:cmd_2_instance) { cmd_2_class.new }

    before do
      cmd_1_class.class_eval { match /test_regex1_[0-9]+/ }
      cmd_2_class.class_eval { match /test_regex2_[a-z]+/ }
      allow(cmd_1_class).to receive(:new) { cmd_1_instance }
      allow(cmd_2_class).to receive(:new) { cmd_2_instance }
    end

    it 'calls process on an instance of each defined command' do
      expect(cmd_1_instance).to receive(:process)
      expect(cmd_2_instance).to receive(:process)

      ChatOps.process('user', 'message')
    end

    it 'calls run only on the command that matched' do
      cmd_2_class.class_eval { def run(user, result); 'Command2.run'; end }

      expect(cmd_1_instance).not_to receive(:run)

      result = ChatOps.process('user', 'test_regex2_abcdef')

      expect(result).to eq 'Command2.run'
    end
  end
end
