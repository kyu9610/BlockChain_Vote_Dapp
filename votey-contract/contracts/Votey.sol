pragma solidity >=0.4.22 <0.9.0;

contract Votey {
    /**
     *** 구조체 생성
     **/

    struct Vote {
        uint256 placeId; // 아이디
        uint256 time; // 시간
        bool isStarted; // 투표 시작,종료 여부
        bool registered; // 후보자 등록 완료.
        string name; // 이름
        string description; // 투표 정보
        address maker; // 개설자
        string imageUrl; // 이미지 url
        Candidate[] candidates; // 후보자 배열
        uint256 candidateCount; // 후보자 수
        Voter[] voter; // 투표자 배열
        address[] register_voter; // 유권자 등록
        uint256 voterCount; // 투표된 횟수
        bytes32 inviteCode; // 초대코드 해시
    }

    struct Candidate {
        uint256 candidate_id; // 아이디
        string candidate_name; // 이름
        uint256 placeId;
        uint256 vote_count; // 투표 수
    }

    struct Voter {
        address voterAddress;
    }

    /**
     *** 변수 생성
     **/

    mapping(uint256 => Vote) public VoteStore;
    uint256 public voteCount = 0;

    uint256[] public voteIdStore;

    /**
     *** 함수 생성
     **/

    // 투표생성 함수
    function generateVote(
        string memory name,
        string memory description,
        string memory imageUrl,
        bytes32 inviteCode,
        address[] memory register_voter
    ) public {
        Vote storage v = VoteStore[voteCount];
        v.placeId = voteCount;
        v.time = block.timestamp;
        v.isStarted = true;
        v.registered = false;
        v.name = name;
        v.description = description;
        v.imageUrl = imageUrl;
        v.maker = msg.sender;
        v.candidateCount = 0;
        v.voterCount = 0;
        v.inviteCode = inviteCode;
        v.register_voter = register_voter;

        voteIdStore.push(voteCount); // 투표를 만들때 마다 투표 아이디를 저장하는 배열에 추가
        voteCount++;
        emit VoteGenerate(voteCount, block.timestamp, true);
    }

    // 투표의 개수를 출력하는 함수
    function getVoteCount() public view returns (uint256) {
        return voteCount;
    }

    // key값에 맞는 투표를 가져오는 함수
    function getVote(uint256 _key) public view returns (Vote memory) {
        return VoteStore[_key];
    }

    // 모든 투표를 가져오는 함수
    function getVotes() public view returns (Vote[] memory) {
        Vote[] memory votes = new Vote[](voteCount);
        uint256 count = 0;
        for (uint256 i = 0; i < voteCount; i++) {
            votes[count] = VoteStore[i];
            count++;
        }
        return votes;
    }

    /** 진행중인 투표, 종료된 투표 구별하여 출력하는 함수 생성하기 **/

    // 1. 진행중인 투표들을 가져오는 함수 getRunningVote
    function getRunningVote() public view returns (Vote[] memory) {
        Vote[] memory votes = new Vote[](voteCount);
        uint256 count = 0;
        for (uint256 i = 0; i < voteCount; i++) {
            if (VoteStore[i].isStarted == true) {
                votes[count] = VoteStore[i];
                count++;
            }
        }
        return votes;
    }

    // 2. 종료된 투표들을 가져오는 함수 getClosedVote
    function getClosedVote() public view returns (Vote[] memory) {
        Vote[] memory votes = new Vote[](voteCount);
        uint256 count = 0;
        for (uint256 i = 0; i < voteCount; i++) {
            if (VoteStore[i].isStarted == false) {
                votes[count] = VoteStore[i];
                count++;
            }
        }
        return votes;
    }

    // getAllVotesId
    function getAllVotesId() public view returns (uint256[] memory) {
        return voteIdStore;
    }

    // 후보자 생성 함수
    function setCandidate(string memory _name, uint256 _voteId) public {
        require(
            checkDuplicateCandidate(_name, _voteId),
            "The candidate is already Registered"
        );
        VoteStore[_voteId].candidates.push(
            Candidate(VoteStore[_voteId].candidateCount, _name, _voteId, 0)
        );
        VoteStore[_voteId].candidateCount++;

        emit Regestering_candidate(
            VoteStore[_voteId].candidateCount,
            _name,
            _voteId,
            0
        );
    }

    // 후보자의 수를 가져오는 함수
    function getCandidateCount(uint256 _voteId) public view returns (uint256) {
        return VoteStore[_voteId].candidateCount;
    }

    // 후보자를 가져오는 함수
    function getCandidate(uint256 _voteId)
        public
        view
        returns (Candidate[] memory)
    {
        uint256 candidate_count = getCandidateCount(_voteId);
        Candidate[] memory candidates = new Candidate[](candidate_count);
        uint256 count = 0;
        for (uint256 i = 0; i < VoteStore[_voteId].candidateCount; i++) {
            candidates[count] = VoteStore[_voteId].candidates[count];
            count++;
        }

        return candidates;
    }

    // 투표자를 가져오는 함수
    function getVoter(uint256 _voteId) public view returns (Voter[] memory) {
        uint256 voter_count = VoteStore[_voteId].voterCount;
        Voter[] memory voters = new Voter[](voter_count);
        uint256 count = 0;
        for (uint256 i = 0; i < VoteStore[_voteId].voterCount; i++) {
            voters[count] = VoteStore[_voteId].voter[count];
            count++;
        }

        return voters;
    }

    // 후보자 중복 체크 - 오류수정하기
    function checkDuplicateCandidate(string memory _name, uint256 _placeId)
        private
        view
        returns (bool)
    {
        Candidate[] memory candidates = getCandidate(_placeId);
        for (uint256 i = 0; i < candidates.length; i++) {
            string memory Name = candidates[i].candidate_name;
            if (
                keccak256(abi.encodePacked((Name))) ==
                keccak256(abi.encodePacked((_name)))
            ) {
                return false;
            }
        }
        return true;
    }

    // 투표자 중복 체크 - 오류수정하기
    function checkDuplicateVoter(uint256 voteId, address voterAddress)
        private
        view
        returns (bool)
    {
        Voter[] memory voters = getVoter(voteId);
        for (uint256 i = 0; i < voters.length; i++) {
            address comparingVoterAddress = voters[i].voterAddress;
            if (comparingVoterAddress == voterAddress) {
                return false;
            }
        }
        return true;
    }

    // 초대코드 일치확인 함수
    function checkInviteCode(uint256 voteId, string memory inviteCodeInput)
        private
        view
        returns (bool)
    {
        uint256 len = bytes(inviteCodeInput).length;
        bytes32 compareHash = keccak256(abi.encodePacked((inviteCodeInput)));
        if (len > 8) {
            return false;
        }
        if (VoteStore[voteId].inviteCode != compareHash) {
            return false;
        }
        return true;
    }

    // 등록된 유권자확인 함수
    function checkRegVoter(uint256 voteId, address voterAddress)
        private
        view
        returns (bool)
    {
        Vote memory vote = getVote(voteId);

        if (vote.register_voter.length == 0) {
            return true;
        }

        for (uint256 i = 0; i < vote.register_voter.length; i++) {
            address comparingVoterAddress = vote.register_voter[i];
            if (comparingVoterAddress == voterAddress) {
                return true;
            }
        }
        return false;
    }

    // 투표하기 함수
    function addVote(
        uint256 _voteId,
        uint256 _candidate_id,
        address voterAddress,
        string memory inviteCodeInput
    ) public {
        require(
            checkDuplicateVoter(_voteId, voterAddress),
            "You are already vote!!"
        );

        require(
            checkInviteCode(_voteId, inviteCodeInput),
            "Invite code is incorrect!!"
        );

        require(checkRegVoter(_voteId, voterAddress), "You are not voter");

        for (uint256 i = 0; i < VoteStore[_voteId].candidateCount; i++) {
            uint256 candidate_id = VoteStore[_voteId]
                .candidates[i]
                .candidate_id;

            if (_candidate_id == candidate_id) {
                VoteStore[_voteId].candidates[i].vote_count++;
                VoteStore[_voteId].voter.push(Voter(voterAddress));
                VoteStore[_voteId].voterCount++;
            }
        }

        emit Voted(_voteId, voterAddress);
    }

    // 개설자 확인 함수
    function checkMaker(address maker) private view returns (bool) {
        if (maker == msg.sender) {
            return true;
        }
        return false;
    }

    // 투표 시작하기
    function startVote(uint256 _placeID) public {
        require(checkMaker(VoteStore[_placeID].maker), "you're not maker");
        VoteStore[_placeID].registered = true;
    }

    // 투표 끝내기
    function endVote(uint256 _placeID) public {
        require(checkMaker(VoteStore[_placeID].maker), "you're not maker");
        VoteStore[_placeID].isStarted = false;
        emit EndVote(_placeID);
    }

    event Regestering_candidate(
        uint256 candidate_id,
        string name,
        uint256 place_id,
        uint256 total_vote
    );
    event EndVote(uint256 _placeID);
    event Voted(uint256 place_id, address voter_address);
    event VoteGenerate(uint256 voteCount, uint256 time, bool isStarted);
}
