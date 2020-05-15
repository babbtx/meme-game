require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "rejects invitees that aren't a list of strings" do
    game = Game.new invitees: 'string'
    game.expects(:send_invites).never
    assert !game.save, "expected invalid invitees"
    assert game.errors.added?(:invitees, :invalid), "expected invalid invitees. Got errors: #{game.errors.full_messages.to_sentence}"
    game = Game.new invitees: %w[ not_valid username@eample.com ]
    game.expects(:send_invites).never
    assert !game.save, "expected invalid invitees"
    assert game.errors.added?(:invitees, :invalid), "expected invalid invitees. Got errors: #{game.errors.full_messages.to_sentence}"
  end

  test "accepts valid invitees" do
    game = Game.new
    game.expects(:send_invites).never
    assert game.save, "expected no invitees to save ok. Got errors: #{game.errors.full_messages.to_sentence}"
    game = Game.new invitees: %w[ valid1@example.com valid2@example.com ]
    game.expects(:send_invites).once
    assert game.save, "expected list of emails to save ok. Got errors: #{game.errors.full_messages.to_sentence}"
  end
end
