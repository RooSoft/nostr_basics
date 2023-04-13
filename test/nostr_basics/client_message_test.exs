defmodule NostrBasics.ClientMessageTest do
  use ExUnit.Case, async: true

  alias NostrBasics.ClientMessage

  doctest ClientMessage

  test "damus initial request" do
    req =
      ~s(["REQ","282C494A-BEB6-40C7-AD43-A33298BE077F",{"kinds":[1,42,7,6],"authors":["bdbe1bdbc9b25a8d89d8fdaf0be1a0dcd837bac9691f597892903a5fdd86e27f","32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245","5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"limit":500}])

    result = ClientMessage.parse(req)

    assert {:req,
            [
              %NostrBasics.Filter{
                subscription_id: "282C494A-BEB6-40C7-AD43-A33298BE077F",
                limit: 500,
                ids: [],
                authors: [
                  <<0xBDBE1BDBC9B25A8D89D8FDAF0BE1A0DCD837BAC9691F597892903A5FDD86E27F::256>>,
                  <<0x32E1827635450EBB3C5A7D12C1F8E7B2B514439AC10A67EEF3D9FD9C5C68E245::256>>,
                  <<0x5AB9F2EFB1FDA6BC32696F6F3FD715E156346175B93B6382099D23627693C3F2::256>>
                ],
                kinds: [1, 42, 7, 6],
                e: [],
                p: []
              }
            ]} == result
  end

  test "damus second request" do
    req =
      ~s(["REQ","E9D809BC-4511-4D19-A099-BC98600E7506",{"kinds":[0],"authors":["bdbe1bdbc9b25a8d89d8fdaf0be1a0dcd837bac9691f597892903a5fdd86e27f","32e1827635450ebb3c5a7d12c1f8e7b2b514439ac10a67eef3d9fd9c5c68e245","5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"]},{"kinds":[3,0],"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"]},{"kinds":[30000],"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"],"#d":["mute"]}])

    result = ClientMessage.parse(req)

    assert {
             :req,
             [
               %NostrBasics.Filter{
                 subscription_id: "E9D809BC-4511-4D19-A099-BC98600E7506",
                 ids: [],
                 authors: [
                   <<0xBDBE1BDBC9B25A8D89D8FDAF0BE1A0DCD837BAC9691F597892903A5FDD86E27F::256>>,
                   <<0x32E1827635450EBB3C5A7D12C1F8E7B2B514439AC10A67EEF3D9FD9C5C68E245::256>>,
                   <<0x5AB9F2EFB1FDA6BC32696F6F3FD715E156346175B93B6382099D23627693C3F2::256>>
                 ],
                 kinds: [0],
                 e: [],
                 p: []
               },
               %NostrBasics.Filter{
                 subscription_id: "E9D809BC-4511-4D19-A099-BC98600E7506",
                 ids: [],
                 authors: [
                   <<0x5AB9F2EFB1FDA6BC32696F6F3FD715E156346175B93B6382099D23627693C3F2::256>>
                 ],
                 kinds: [3, 0],
                 e: [],
                 p: []
               },
               %NostrBasics.Filter{
                 subscription_id: "E9D809BC-4511-4D19-A099-BC98600E7506",
                 ids: [],
                 authors: [
                   <<0x5AB9F2EFB1FDA6BC32696F6F3FD715E156346175B93B6382099D23627693C3F2::256>>
                 ],
                 kinds: [30_000],
                 e: [],
                 p: []
               }
             ]
           } == result
  end

  test "damus third request" do
    req =
      ~s(["REQ","85878F46-1063-4785-BBDB-2D2792694D02",{"kinds":[1,42,7,6],"limit":100,"#p":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"]}])

    result = ClientMessage.parse(req)

    assert {
             :req,
             [
               %NostrBasics.Filter{
                 subscription_id: "85878F46-1063-4785-BBDB-2D2792694D02",
                 limit: 100,
                 ids: [],
                 kinds: [1, 42, 7, 6],
                 e: [],
                 p: []
               }
             ]
           } = result
  end

  test "damus fourth request" do
    req =
      ~s(["REQ","5948E1D7-6183-48D5-9023-C29AB1168142",{"kinds":[4],"limit":500,"#p":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"]},{"kinds":[4],"authors":["5ab9f2efb1fda6bc32696f6f3fd715e156346175b93b6382099d23627693c3f2"]}])

    result = ClientMessage.parse(req)

    assert {
             :req,
             [
               %NostrBasics.Filter{
                 subscription_id: "5948E1D7-6183-48D5-9023-C29AB1168142",
                 limit: 500,
                 ids: [],
                 authors: [],
                 kinds: [4],
                 e: [],
                 p: []
               },
               %NostrBasics.Filter{
                 subscription_id: "5948E1D7-6183-48D5-9023-C29AB1168142",
                 since: nil,
                 until: nil,
                 limit: nil,
                 ids: [],
                 authors: [
                   <<0x5AB9F2EFB1FDA6BC32696F6F3FD715E156346175B93B6382099D23627693C3F2::256>>
                 ],
                 kinds: [4],
                 e: [],
                 p: []
               }
             ]
           } == result
  end

  test "damus fifth request" do
    req = ~s(["CLOSE","0E3A49CC-9AA4-4115-9BA0-EC56D97AC535"])

    result = ClientMessage.parse(req)

    assert {:close,
            %NostrBasics.CloseRequest{subscription_id: "0E3A49CC-9AA4-4115-9BA0-EC56D97AC535"}} ==
             result
  end
end
