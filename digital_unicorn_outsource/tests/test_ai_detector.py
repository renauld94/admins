import unittest
from digital_unicorn_outsource import ai_detector


class TestAIDetector(unittest.TestCase):
    def test_human_like_text(self):
        text = """
        I went to the store yesterday. I bought some apples and bread.
        It was sunny and I enjoyed the walk.
        """
        res = ai_detector.analyze_text(text)
        self.assertIn('score', res)
        self.assertLessEqual(res['score'], 0.6)
        self.assertIn(res['verdict'], ('human', 'uncertain'))
        self.assertIn('burstiness', res['features'])
        self.assertIn('perplexity_approx', res['features'])

    def test_ai_like_text(self):
        text = (
            "As an AI language model, I do not have access to external databases. "
            "However, I can provide an explanation of the underlying principles. "
            "Furthermore, this approach allows for better generalization across datasets."
        )
        res = ai_detector.analyze_text(text)
        self.assertIn('score', res)
        self.assertGreaterEqual(res['score'], 0.5)
        self.assertIn(res['verdict'], ('ai', 'uncertain'))
        self.assertGreater(res['features']['ai_phrase_count'], 0)

    def test_empty(self):
        res = ai_detector.analyze_text('')
        self.assertEqual(res['score'], 0.0)
        self.assertEqual(res['verdict'], 'uncertain')

    def test_burstiness(self):
        consistent_text = "This is a sentence. This is another sentence. This is yet another sentence."
        bursty_text = "Hi. This is a very long sentence with many words that goes on and on. Short."
        res_consistent = ai_detector.analyze_text(consistent_text)
        res_bursty = ai_detector.analyze_text(bursty_text)
        self.assertGreater(res_bursty['features']['burstiness'], res_consistent['features']['burstiness'])

    def test_report_generation(self):
        results = {
            '/path/file1.txt': {'score': 0.8, 'verdict': 'ai', 'features': {'ai_phrase_count': 1, 'total_words': 100}},
            '/path/file2.txt': {'score': 0.2, 'verdict': 'human', 'features': {'ai_phrase_count': 0, 'total_words': 50}}
        }
        report = ai_detector.generate_report(results, 'markdown', 0.5)
        self.assertIn('# AI Detection Report', report)
        self.assertIn('file1.txt', report)
        self.assertIn('file2.txt', report)


if __name__ == '__main__':
    unittest.main()
