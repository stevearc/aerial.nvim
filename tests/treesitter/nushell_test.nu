module MY_MODULE {
  export const MY_CONSTANT = "X"

  def PRIVATE_DEF [] { }
  export def PUBLIC_DEF [] { }
  export def "DEF WITH SPACES" [] { }

  module MY_SUB_MODULE {
    export const MY_SUB_CONSTANT = "XX"
    def SUB_PRIVATE_DEF [] { }
    export def SUB_PUBLIC_DEF [] { }
  }
}
