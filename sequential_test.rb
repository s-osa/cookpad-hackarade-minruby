MY_PROGRAM = 'interp.rb'

Dir.glob('test*.rb').sort.each do |f|
  if f == 'test4-4.rb'
    print "\033[93m#{f}\033[0m\n"
    next
  end

  correct = `ruby #{f}`
  answer = `ruby #{MY_PROGRAM} #{MY_PROGRAM} #{f}`

  if correct == answer
    print "\033[92m#{f}\033[0m\n"

  else
    print "\033[91m#{f}\033[0m\n"
    break
  end
end
