guard :shell, source: './src.iced' do

  watch /(test.iced\/.+\.iced$)/ do
    `make ice_tests`
  end

  watch /(src.iced\/(?!.*automagic.*\.iced$).*\.iced$)/ do
    `make build_trakio`
  end

  watch /(src.iced\/trakio\/(automagic|lodash).*\.iced$)/ do
    `make build_automagic`
  end

  # watch /(src.iced\/.+\.iced$)/ do
  #   `make ice_tests`
  # end

  # watch /(.+\.iced$)/ do
  #   `make build`
  # end

  # watch /(automagic.+\.iced$)|config/ do
  #   `make build_automagic`
  # end

end
