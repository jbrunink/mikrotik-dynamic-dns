:global stripNetmask do={
  :return [:pick $ipaddress 0 [:find $ipaddress "/"]]
}

:global oldIPv6Address [/file get [/file find name="flash/oldipv6.txt"] contents]
:global oldIPv4Address [/file get [/file find name="flash/oldipv4.txt"] contents]
:global currentIPv6Address nil
:global currentIPv4Address ([/ip address get [/ip address find interface="caiw-internet"]]->"address")   

:global address nil

:foreach key,value in=[/ipv6 address find interface="tun01"] do={
  :local address [/ipv6 address get $key]
  if (($address->"link-local") = nil) do={
    :global currentIPv6Address ($address->"address")
  }
}

:do {
  if ($oldIPv4Address != $currentIPv4Address) do={
    :set address [$stripNetmask ipaddress=$currentIPv4Address]
    :put ("IPv4 address (".$address.") has changed, updating it")
    :do {
      :log info ("ipv4 (".$address.") address changed; running update-ipv4 script")
      /system script run "update-ipv4"
      /file set "flash/oldipv4.txt" contents=$currentIPv4Address
    } on-error={
      :log warning "failed to run update-ipv4 script"
    }
  }
  if ($oldIPv6Address != $currentIPv6Address) do={
    :set address [$stripNetmask ipaddress=$currentIPv6Address]
    :put ("IPv6 address (".$address.") has changed, updating it")
    :do {
      :log info ("ipv6 (".$address.") address changed; running update-ipv6 script")
      /system script run "update-ipv6"
      /file set "flash/oldipv6.txt" contents=$currentIPv6Address
    } on-error={
      :log warning "failed to run update-ipv6 script"
    }
  }
} on-error={
  :log warning "Something went wrong with trying to update IP"
}